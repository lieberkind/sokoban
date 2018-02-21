module Game
    exposing
        ( Grid
        , Game
        , Direction(Left, Up, Right, Down)
        , GameObject(..)
        , SpaceType(..)
        , MovingObject(..)
        , emptyGame
        , move
        )

import Matrix exposing (..)


type SpaceType
    = GoalField
    | Path


type MovingObject
    = Player
    | Crate



-- Needing to have "kind" as a field in the record seems wrong. How do I fix that?


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
    , playerLocation : Location
    }


emptyGame : Game
emptyGame =
    Game
        (Matrix.fromList
            [ [ Block, Block, Block, Block, Block, Block, Block ]
            , [ Block, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Block ]
            , [ Block, Space { occupant = Just Player, kind = Path }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Block ]
            , [ Block, Space { occupant = Nothing, kind = Path }, Space { occupant = Just Crate, kind = Path }, Space { occupant = Just Crate, kind = Path }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Block ]
            , [ Block, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = GoalField }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Block ]
            , [ Block, Space { occupant = Nothing, kind = GoalField }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Space { occupant = Nothing, kind = Path }, Block ]
            , [ Block, Block, Block, Block, Block, Block, Block ]
            ]
        )
        ( 2, 1 )


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

        movePlayer : Occupyable r -> Occupyable r -> Grid -> Grid
        movePlayer o1 o2 grid =
            grid
                |> Matrix.set game.playerLocation (o1 |> empty)
                |> Matrix.set oneSpaceAway (o2 |> occupyWith Player)

        pushCrate : Occupyable r -> Occupyable r -> Occupyable r -> Grid -> Grid
        pushCrate o1 o2 o3 grid =
            movePlayer o1 o2 grid
                |> Matrix.set twoSpacesAway (o3 |> occupyWith Crate)
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

            ( Space s1, Space s2, Block ) ->
                case s2.occupant of
                    Just _ ->
                        Result.Err BlockedByCrate

                    Nothing ->
                        Result.Ok
                            { game | playerLocation = oneSpaceAway, grid = movePlayer s1 s2 game.grid }

            ( Space s1, Space s2, Space s3 ) ->
                case ( s2.occupant, s3.occupant ) of
                    ( Nothing, _ ) ->
                        Result.Ok
                            { game | playerLocation = oneSpaceAway, grid = movePlayer s1 s2 game.grid }

                    ( Just Crate, Nothing ) ->
                        Result.Ok
                            { game | playerLocation = oneSpaceAway, grid = pushCrate s1 s2 s3 game.grid }

                    ( Just Crate, Just _ ) ->
                        Result.Err BlockedByCrate

                    _ ->
                        Result.Err Impossible

            _ ->
                Result.Err Impossible
