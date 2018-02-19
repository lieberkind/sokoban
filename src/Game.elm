module Game
    exposing
        ( Grid
        , Game
        , Direction(Left, Up, Right, Down)
        , GameObject(..)
        , empty
        , move
        )

import Matrix exposing (..)
import Set exposing (Set)


type SpaceType
    = GoalField
    | Path


type MovingObject
    = Player
    | Crate


type GameObject
    = Block
    | Space { occupant : Maybe MovingObject, kind : SpaceType }


type alias Occupyable r =
    { r | occupant : Maybe MovingObject, kind : SpaceType }


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
    Matrix GameObject


type alias Game =
    { grid : Matrix GameObject
    , goalFields : Set Location
    , playerLocation : Location
    }


occupyWith : MovingObject -> Occupyable r -> GameObject
occupyWith obj r =
    Space { kind = r.kind, occupant = Just obj }


empty : Occupyable r -> GameObject
empty r =
    Space { kind = r.kind, occupant = Nothing }


getAdjacentLocation : Location -> Direction -> Location
getAdjacentLocation location direction =
    let
        ( row, col ) =
            location
    in
        case direction of
            Left ->
                loc row (col - 1)

            Up ->
                loc (row - 1) col

            Right ->
                loc row (col + 1)

            Down ->
                loc (row + 1) col


objectAt : Location -> Matrix GameObject -> GameObject
objectAt loc mat =
    Matrix.get loc mat |> Maybe.withDefault Block


move : Direction -> Game -> Result MoveError Game
move direction game =
    let
        oneSpaceAway : Location
        oneSpaceAway =
            getAdjacentLocation game.playerLocation direction

        twoSpacesAway : Location
        twoSpacesAway =
            getAdjacentLocation oneSpaceAway direction
    in
        case
            ( objectAt game.playerLocation game.grid
            , objectAt oneSpaceAway game.grid
            , objectAt twoSpacesAway game.grid
            )
        of
            -- There is a block in the way
            ( _, Block, _ ) ->
                Result.Err BlockedByBlock

            ( Space s1, Space s2, Space s3 ) ->
                case ( s2.occupant, s3.occupant ) of
                    ( Nothing, _ ) ->
                        Result.Ok
                            { game
                                | playerLocation = oneSpaceAway
                                , grid =
                                    game.grid
                                        |> Matrix.set game.playerLocation (s1 |> empty)
                                        |> Matrix.set oneSpaceAway (s2 |> occupyWith Player)
                            }

                    ( Just Crate, Nothing ) ->
                        Result.Ok
                            { game
                                | playerLocation = oneSpaceAway
                                , grid =
                                    game.grid
                                        |> Matrix.set game.playerLocation (s1 |> empty)
                                        |> Matrix.set oneSpaceAway (s2 |> occupyWith Player)
                                        |> Matrix.set twoSpacesAway (s3 |> occupyWith Crate)
                            }

                    ( Just Crate, Just _ ) ->
                        Result.Err BlockedByCrate

                    _ ->
                        Result.Err Impossible

            _ ->
                Result.Err Impossible
