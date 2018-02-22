module Data.Game
    exposing
        ( Move(..)
        , Grid
        , Game
        , Direction(Left, Up, Right, Down)
        , MoveError(..)
        , move
        , hasWon
        , fromLevel
        , grid
        )

import Matrix exposing (Matrix, Location)
import Data.Level exposing (Level)
import Data.GameElement as Element exposing (GameElement(..), Occupyable, MovingObject(..))


type Move
    = Move
    | Push


type Direction
    = Left
    | Up
    | Right
    | Down


type MoveError
    = BlockedByCrate
    | BlockedByBlock
    | OutOfBounds
    | Impossible


type alias Grid =
    Matrix GameElement


type Game
    = Game { grid : Grid, playerLocation : Location }


{-| The only way to instantiate a new game. Should contain validation of
the passed level to make sure that it's "correct"
-}
fromLevel : Level -> Game
fromLevel lvl =
    let
        fromStrings : List String -> Grid
        fromStrings strs =
            strs
                |> List.map (String.split "")
                |> Matrix.fromList
                |> Matrix.map Element.fromString
    in
        Game { lvl | grid = (fromStrings lvl.grid) }


move : Direction -> Game -> Result MoveError ( Game, Move )
move direction (Game game) =
    let
        grid : Grid
        grid =
            game.grid

        oneSpaceAway : Location
        oneSpaceAway =
            getAdjacentLocation game.playerLocation direction

        twoSpacesAway : Location
        twoSpacesAway =
            getAdjacentLocation oneSpaceAway direction

        movePlayer : Occupyable r -> Occupyable r -> Grid -> Grid
        movePlayer o1 o2 grid =
            grid
                |> Matrix.set game.playerLocation (Element.deoccupy o1)
                |> Matrix.set oneSpaceAway (Element.occupyWith Player o2)

        pushCrate : Occupyable r -> Occupyable r -> Occupyable r -> Grid -> Grid
        pushCrate o1 o2 o3 grid =
            movePlayer o1 o2 grid
                |> Matrix.set twoSpacesAway (Element.occupyWith Crate o3)
    in
        case
            ( elementAt game.playerLocation grid
            , elementAt oneSpaceAway grid
            , elementAt twoSpacesAway grid
            )
        of
            -- There is a block in the way
            ( _, Block, _ ) ->
                Result.Err BlockedByBlock

            -- There's a block two spaces away
            ( Space s1, Space s2, Block ) ->
                case s2.occupant of
                    Just _ ->
                        Result.Err BlockedByCrate

                    Nothing ->
                        Result.Ok
                            ( Game { game | playerLocation = oneSpaceAway, grid = movePlayer s1 s2 grid }
                            , Move
                            )

            -- There are two adjacent spaces, potentially occupied by crates
            ( Space s1, Space s2, Space s3 ) ->
                case ( s2.occupant, s3.occupant ) of
                    ( Nothing, _ ) ->
                        Result.Ok
                            ( Game { game | playerLocation = oneSpaceAway, grid = movePlayer s1 s2 grid }
                            , Move
                            )

                    ( Just Crate, Nothing ) ->
                        Result.Ok
                            ( Game { game | playerLocation = oneSpaceAway, grid = pushCrate s1 s2 s3 grid }
                            , Push
                            )

                    ( Just Crate, Just _ ) ->
                        Result.Err BlockedByCrate

                    _ ->
                        Result.Err Impossible

            _ ->
                Result.Err Impossible


hasWon : Game -> Bool
hasWon (Game { grid }) =
    grid
        |> Matrix.toList
        |> List.foldr (++) []
        |> List.filter Element.isGoalField
        |> List.all Element.hasCrate


grid : Game -> Grid
grid (Game { grid }) =
    grid



-- HELPERS


getAdjacentLocation : Location -> Direction -> Location
getAdjacentLocation location direction =
    let
        ( row, col ) =
            location
    in
        case direction of
            Left ->
                Matrix.loc row (col - 1)

            Up ->
                Matrix.loc (row - 1) col

            Right ->
                Matrix.loc row (col + 1)

            Down ->
                Matrix.loc (row + 1) col


elementAt : Location -> Grid -> GameElement
elementAt loc grid =
    Matrix.get loc grid |> Maybe.withDefault Block
