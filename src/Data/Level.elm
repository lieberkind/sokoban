module Data.Level
    exposing
        ( Grid
        , Level
        , fromTemplate
        , grid
        , hasWon
        , move
        , moves
        , nextPlayerMood
        , number
        , pushes
        , reset
        , undo
        )

import Matrix exposing (Matrix, Location)
import Data.LevelTemplate exposing (LevelTemplate)
import Data.GameElement as Element exposing (GameElement(..), Occupant(..), Occupyable)
import Data.Movement exposing (Direction(..), MoveError(..))
import Data.Cyclic as Cyclic


type alias Grid =
    Matrix GameElement



-- LEVEL


type alias LevelState =
    { grid : Grid, playerLocation : Location, moves : Int, pushes : Int }


type alias Level =
    { number : Int
    , initial : LevelState
    , previous : Maybe LevelState
    , current : LevelState
    }


fromTemplate : LevelTemplate -> Level
fromTemplate tmpl =
    let
        fromStrings : List String -> Grid
        fromStrings strs =
            strs
                |> List.map (String.split "")
                |> Matrix.fromList
                |> Matrix.map Element.fromString

        levelState =
            { grid = (fromStrings tmpl.grid), playerLocation = tmpl.playerLocation, moves = 0, pushes = 0 }
    in
        { current = levelState, initial = levelState, previous = Nothing, number = tmpl.levelNumber }


hasWon : Level -> Bool
hasWon { current } =
    current.grid
        |> Matrix.toList
        |> List.foldr (++) []
        |> List.filter Element.isGoalField
        |> List.all Element.hasCrate


grid : Level -> Grid
grid { current } =
    current.grid


{-| This function needs refactoring... It's simply not nice enough
-}
move : Direction -> Level -> Result MoveError Level
move direction level =
    let
        lvl : LevelState
        lvl =
            level.current

        grid : Grid
        grid =
            lvl.grid

        oneSpaceAway : Location
        oneSpaceAway =
            getAdjacentLocation lvl.playerLocation direction

        twoSpacesAway : Location
        twoSpacesAway =
            getAdjacentLocation oneSpaceAway direction

        movePlayer : Occupyable -> Occupyable -> Grid -> Grid
        movePlayer o1 o2 grid =
            grid
                |> Matrix.set lvl.playerLocation (Element.deoccupy o1)
                |> Matrix.set oneSpaceAway (Element.occupyWith o1.occupant o2)

        pushCrate : Occupyable -> Occupyable -> Occupyable -> Grid -> Grid
        pushCrate o1 o2 o3 grid =
            movePlayer o1 o2 grid
                |> Matrix.set twoSpacesAway (Element.occupyWith Crate o3)
    in
        case
            ( elementAt lvl.playerLocation grid
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
                    None ->
                        let
                            newCurrent =
                                { lvl
                                    | grid = (movePlayer s1 s2 grid)
                                    , playerLocation = oneSpaceAway
                                    , moves = lvl.moves + 1
                                }
                        in
                            Result.Ok
                                { level | current = newCurrent, previous = Just lvl }

                    _ ->
                        Result.Err BlockedByCrate

            -- There are two adjacent spaces, potentially occupied by crates
            ( Space s1, Space s2, Space s3 ) ->
                case ( s2.occupant, s3.occupant ) of
                    ( None, _ ) ->
                        let
                            newCurrent =
                                { lvl
                                    | grid = (movePlayer s1 s2 grid)
                                    , playerLocation = oneSpaceAway
                                    , moves = lvl.moves + 1
                                }
                        in
                            Result.Ok
                                { level | current = newCurrent, previous = Just lvl }

                    ( Crate, None ) ->
                        let
                            newCurrent =
                                { grid = (pushCrate s1 s2 s3 grid)
                                , playerLocation = oneSpaceAway
                                , moves = lvl.moves + 1
                                , pushes = lvl.pushes + 1
                                }
                        in
                            Result.Ok
                                { level | current = newCurrent, previous = Just lvl }

                    ( Crate, _ ) ->
                        Result.Err BlockedByCrate

                    _ ->
                        Result.Err Impossible

            _ ->
                Result.Err Impossible


undo : Level -> Level
undo lvl =
    case lvl.previous of
        Just lvlState ->
            { lvl | current = lvlState, previous = Nothing }

        Nothing ->
            lvl


reset : Level -> Level
reset lvl =
    { lvl | current = lvl.initial, previous = Nothing }


moves : Level -> Int
moves lvl =
    lvl.current.moves


pushes : Level -> Int
pushes lvl =
    lvl.current.pushes


number : Level -> Int
number lvl =
    lvl.number


{-| This could probably be a lot nicer
-}
nextPlayerMood : Level -> Level
nextPlayerMood level =
    let
        nextPlayerMood levelState =
            let
                element =
                    Matrix.get levelState.playerLocation levelState.grid |> Maybe.withDefault Block
            in
                case element of
                    Space s ->
                        case s.occupant of
                            Player moods ->
                                { levelState
                                    | grid =
                                        Matrix.set
                                            levelState.playerLocation
                                            (Space { s | occupant = (Player (Cyclic.next moods)) })
                                            levelState.grid
                                }

                            _ ->
                                levelState

                    _ ->
                        levelState
    in
        { level | current = nextPlayerMood level.current, previous = Maybe.map nextPlayerMood level.previous }



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
