module Game
    exposing
        ( Grid
        , Game
        , Direction(Left, Up, Right, Down)
        , GameObject(FreeSpace, Block, Crate, Player)
        , empty
        , move
        )

import Matrix exposing (..)
import Set exposing (Set)


type GameObject
    = FreeSpace
    | Block
    | Crate
    | Player


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


empty : Game
empty =
    Game
        (Matrix.fromList
            [ [ Block, Block, Block, Block, Block, Block, Block ]
            , [ Block, FreeSpace, FreeSpace, FreeSpace, FreeSpace, FreeSpace, Block ]
            , [ Block, Player, FreeSpace, FreeSpace, FreeSpace, FreeSpace, Block ]
            , [ Block, FreeSpace, Crate, Crate, FreeSpace, FreeSpace, Block ]
            , [ Block, FreeSpace, FreeSpace, FreeSpace, FreeSpace, FreeSpace, Block ]
            , [ Block, FreeSpace, FreeSpace, FreeSpace, FreeSpace, FreeSpace, Block ]
            , [ Block, Block, Block, Block, Block, Block, Block ]
            ]
        )
        Set.empty
        ( 2, 1 )


move : Direction -> Game -> Result MoveError Game
move direction game =
    let
        oneSpaceAway : Location
        oneSpaceAway =
            getAdjacentLocation game.playerLocation direction

        twoSpacesAway : Location
        twoSpacesAway =
            getAdjacentLocation oneSpaceAway direction

        movePlayer : Game -> Matrix GameObject
        movePlayer game =
            game.grid
                |> Matrix.set game.playerLocation FreeSpace
                |> Matrix.set oneSpaceAway Player

        pushCrate : Game -> Matrix GameObject
        pushCrate game =
            movePlayer game
                |> Matrix.set twoSpacesAway Crate
    in
        case ( Matrix.get oneSpaceAway game.grid, Matrix.get twoSpacesAway game.grid ) of
            ( Just Crate, Just FreeSpace ) ->
                Result.Ok { game | grid = pushCrate game, playerLocation = oneSpaceAway }

            ( Just FreeSpace, _ ) ->
                Result.Ok { game | grid = movePlayer game, playerLocation = oneSpaceAway }

            ( Nothing, _ ) ->
                Result.Err OutOfBounds

            ( Just Block, _ ) ->
                Result.Err BlockedByBlock

            ( Just Crate, Just obj ) ->
                Result.Err BlockedByCrate

            _ ->
                Result.Err Impossible
