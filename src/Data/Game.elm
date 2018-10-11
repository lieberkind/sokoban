module Data.Game exposing
    ( Game
    , advanceLevel
    , currentLevel
    , fromProgress
    , getTotalMoves
    , getTotalPushes
    , isGameOver
    , isPlaying
    , levelWon
    , move
    , new
    , toProgress
    , undoLevel
    , undoMove
    )

import Data.Level as Level exposing (..)
import Data.LevelTemplate as LevelTemplate exposing (LevelTemplate)
import Data.Movement exposing (Direction, MoveError(..))
import Data.Progress exposing (Progress)
import List.Nonempty as NE exposing (Nonempty(..))


type GameState
    = Playing
    | LevelWon
    | GameOver


type Game
    = Game
        { state : GameState
        , levels : Nonempty Level
        , totalMoves : Int
        , totalPushes : Int
        }


new : Game
new =
    Game
        { state = Playing
        , levels = NE.map Level.fromTemplate LevelTemplate.allLevels
        , totalMoves = 0
        , totalPushes = 0
        }


fromProgress : Progress -> Game
fromProgress { levelNumber, totalMoves, totalPushes } =
    let
        levelsToPlay =
            LevelTemplate.allLevels
                |> NE.toList
                |> List.filter (\template -> template.levelNumber >= levelNumber)
                |> NE.fromList
                |> Maybe.withDefault LevelTemplate.allLevels
                |> NE.map Level.fromTemplate
    in
    Game
        { state = Playing
        , levels = levelsToPlay
        , totalMoves = totalMoves
        , totalPushes = totalPushes
        }


move : Direction -> Game -> Result MoveError Game
move dir ((Game { state }) as game) =
    case state of
        Playing ->
            Level.move dir (safeCurrentLevel game) |> Result.map (updateGame game)

        _ ->
            Result.Ok game


undoMove : Game -> Game
undoMove ((Game { state }) as game) =
    case state of
        Playing ->
            updateGame game (Level.undo (safeCurrentLevel game))

        _ ->
            game


undoLevel : Game -> Game
undoLevel ((Game { state }) as game) =
    case state of
        GameOver ->
            game

        _ ->
            updateGame game (Level.reset (safeCurrentLevel game))


currentLevel : Game -> Maybe Level
currentLevel game =
    if isGameOver game then
        Nothing

    else
        Just (safeCurrentLevel game)


advanceLevel : Game -> Game
advanceLevel ((Game { state, levels, totalMoves, totalPushes }) as game) =
    case state of
        LevelWon ->
            case NE.tail levels of
                [] ->
                    Game
                        { levels = levels
                        , state = GameOver
                        , totalMoves = totalMoves + Level.moves (safeCurrentLevel game)
                        , totalPushes = totalPushes + Level.pushes (safeCurrentLevel game)
                        }

                next :: rest ->
                    Game
                        { state = Playing
                        , levels = Nonempty next rest
                        , totalMoves = totalMoves + Level.moves (safeCurrentLevel game)
                        , totalPushes = totalPushes + Level.pushes (safeCurrentLevel game)
                        }

        _ ->
            game


levelWon : Game -> Bool
levelWon (Game game) =
    case game.state of
        LevelWon ->
            True

        _ ->
            False


isPlaying : Game -> Bool
isPlaying (Game game) =
    if game.state == Playing then
        True

    else
        False


isGameOver : Game -> Bool
isGameOver (Game game) =
    if game.state == GameOver then
        True

    else
        False


toProgress : Game -> Maybe Progress
toProgress ((Game { state, totalMoves, totalPushes }) as game) =
    case state of
        GameOver ->
            Nothing

        _ ->
            Just
                { levelNumber = Level.number (safeCurrentLevel game)
                , totalMoves = totalMoves
                , totalPushes = totalPushes
                }


getTotalMoves : Game -> Int
getTotalMoves (Game { totalMoves }) =
    totalMoves


getTotalPushes : Game -> Int
getTotalPushes (Game { totalPushes }) =
    totalPushes



-- HELPERS


updateGame : Game -> Level -> Game
updateGame (Game game) level =
    let
        newGameState =
            if Level.hasWon level then
                LevelWon

            else
                Playing

        newLevels =
            Nonempty level (NE.tail game.levels)
    in
    Game { game | levels = newLevels, state = newGameState }


safeCurrentLevel : Game -> Level
safeCurrentLevel (Game { levels }) =
    NE.head levels
