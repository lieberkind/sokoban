module Game
    exposing
        ( Move
        , Grid
        , Game
        , Direction(Left, Up, Right, Down)
        , GameObject(..)
        , SpaceType(..)
        , MovingObject(..)
        , emptyGame
        , move
        , hasWon
        )

import Matrix exposing (Matrix, Location)


type Move
    = Move
    | Push


type SpaceType
    = GoalField
    | Path


type MovingObject
    = Player
    | Crate


{-| Needing to have "kind" as a field in the record seems wrong. How do I fix that?
-}
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
    { grid : Grid
    , playerLocation : Location
    }



-- EXPOSED MEMBERS


emptyGame : () -> Game
emptyGame _ =
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


move : Direction -> Game -> Result MoveError ( Game, Move )
move direction game =
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
                |> Matrix.set game.playerLocation (empty o1)
                |> Matrix.set oneSpaceAway (occupyWith Player o2)

        pushCrate : Occupyable r -> Occupyable r -> Occupyable r -> Grid -> Grid
        pushCrate o1 o2 o3 grid =
            movePlayer o1 o2 grid
                |> Matrix.set twoSpacesAway (occupyWith Crate o3)
    in
        case
            ( objectAt game.playerLocation grid
            , objectAt oneSpaceAway grid
            , objectAt twoSpacesAway grid
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
                            ( { game | playerLocation = oneSpaceAway, grid = movePlayer s1 s2 grid }
                            , Move
                            )

            -- There are two adjacent spaces, potentially occupied by crates
            ( Space s1, Space s2, Space s3 ) ->
                case ( s2.occupant, s3.occupant ) of
                    ( Nothing, _ ) ->
                        Result.Ok
                            ( { game | playerLocation = oneSpaceAway, grid = movePlayer s1 s2 grid }
                            , Move
                            )

                    ( Just Crate, Nothing ) ->
                        Result.Ok
                            ( { game | playerLocation = oneSpaceAway, grid = pushCrate s1 s2 s3 grid }
                            , Push
                            )

                    ( Just Crate, Just _ ) ->
                        Result.Err BlockedByCrate

                    _ ->
                        Result.Err Impossible

            _ ->
                Result.Err Impossible


hasWon : Game -> Bool
hasWon { grid } =
    grid
        |> Matrix.toList
        |> List.foldr (++) []
        |> List.filter isGoalField
        |> List.all hasCrate



-- HELPERS


isGoalField : GameObject -> Bool
isGoalField obj =
    case obj of
        Space { kind } ->
            case kind of
                GoalField ->
                    True

                _ ->
                    False

        _ ->
            False


hasCrate : GameObject -> Bool
hasCrate obj =
    case obj of
        Space { occupant } ->
            case occupant of
                Just Crate ->
                    True

                _ ->
                    False

        _ ->
            False


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
                Matrix.loc row (col - 1)

            Up ->
                Matrix.loc (row - 1) col

            Right ->
                Matrix.loc row (col + 1)

            Down ->
                Matrix.loc (row + 1) col


objectAt : Location -> Grid -> GameObject
objectAt loc mat =
    Matrix.get loc mat |> Maybe.withDefault Block
