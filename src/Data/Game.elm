module Data.Game
    exposing
        ( Game
        , advanceLevel
        , currentLevel
        , initialise
        , initialiseFromSaved
        , isGameOver
        , isPlaying
        , levelWon
        , move
        , toProgress
        , undoLevel
        , undoMove
        )

import Data.Level as Level exposing (..)
import Data.Movement exposing (Direction, MoveError(..))
import Data.LevelTemplate exposing (LevelTemplate)
import Data.Progress exposing (Progress)


type GameState
    = Playing
    | LevelWon
    | GameOver


type alias Game =
    { state : GameState
    , currentLevel : Level
    , remainingLevels : List Level
    , totalMoves : Int
    , totalPushes : Int
    }


initialise : LevelTemplate -> List LevelTemplate -> Game
initialise first remaining =
    { state = Playing
    , currentLevel = Level.fromTemplate first
    , remainingLevels = List.map Level.fromTemplate remaining
    , totalMoves = 0
    , totalPushes = 0
    }


initialiseFromSaved : Progress -> List LevelTemplate -> Maybe Game
initialiseFromSaved { levelNumber, totalMoves, totalPushes } levels =
    let
        levelsToPlay =
            levels
                |> List.filter (\template -> template.levelNumber >= levelNumber)

        first =
            List.head levelsToPlay

        remaining =
            List.tail levelsToPlay
    in
        Maybe.map2 initialise first remaining
            |> Maybe.map (\game -> { game | totalMoves = totalMoves, totalPushes = totalPushes })


move : Direction -> Game -> Result MoveError Game
move dir game =
    case game.state of
        Playing ->
            Level.move dir game.currentLevel |> Result.map (updateGame game)

        _ ->
            Result.Ok game


updateGame : Game -> Level -> Game
updateGame game level =
    let
        newGameState =
            if Level.hasWon level then
                LevelWon
            else
                Playing
    in
        { game | currentLevel = level, state = newGameState }


undoMove : Game -> Game
undoMove game =
    case game.state of
        Playing ->
            updateGame game (Level.undo game.currentLevel)

        _ ->
            game


undoLevel : Game -> Game
undoLevel game =
    case game.state of
        GameOver ->
            game

        _ ->
            updateGame game (Level.reset game.currentLevel)


currentLevel : Game -> Maybe Level
currentLevel game =
    if isGameOver game then
        Nothing
    else
        Just game.currentLevel


advanceLevel : Game -> Game
advanceLevel game =
    case game.state of
        LevelWon ->
            case game.remainingLevels of
                [] ->
                    { game
                        | state = GameOver
                        , totalMoves = game.totalMoves + (Level.moves game.currentLevel)
                        , totalPushes = game.totalPushes + (Level.pushes game.currentLevel)
                    }

                next :: rest ->
                    { game
                        | state = Playing
                        , currentLevel = next
                        , remainingLevels = rest
                        , totalMoves = game.totalMoves + (Level.moves game.currentLevel)
                        , totalPushes = game.totalPushes + (Level.pushes game.currentLevel)
                    }

        _ ->
            game


levelWon : Game -> Bool
levelWon { state } =
    case state of
        LevelWon ->
            True

        _ ->
            False


isPlaying : Game -> Bool
isPlaying game =
    if game.state == Playing then
        True
    else
        False


isGameOver : Game -> Bool
isGameOver game =
    if game.state == GameOver then
        True
    else
        False


toProgress : Game -> Maybe Progress
toProgress game =
    case game.state of
        GameOver ->
            Nothing

        _ ->
            Just
                { levelNumber = Level.number game.currentLevel
                , totalMoves = game.totalMoves
                , totalPushes = game.totalPushes
                }
