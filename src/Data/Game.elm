module Data.Game
    exposing
        ( Game
        , Progress
        , advanceLevel
        , currentLevel
        , fromProgress
        , isGameOver
        , isPlaying
        , levelWon
        , move
        , new
        , nextPlayerMood
        , toProgress
        , undoLevel
        , undoMove
        )

import Data.Level as Level exposing (..)
import Data.Movement exposing (Direction, MoveError(..))
import Data.LevelTemplate as LevelTemplate exposing (LevelTemplate)
import List.Nonempty as NE exposing (Nonempty(Nonempty))


type alias Progress =
    { levelNumber : Int
    , totalMoves : Int
    , totalPushes : Int
    }


type GameState
    = Playing
    | LevelWon
    | GameOver


type alias Game =
    { state : GameState
    , levels : Nonempty Level
    , totalMoves : Int
    , totalPushes : Int
    }


new : Game
new =
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
        { state = Playing
        , levels = levelsToPlay
        , totalMoves = totalMoves
        , totalPushes = totalPushes
        }


move : Direction -> Game -> Result MoveError Game
move dir game =
    case game.state of
        Playing ->
            Level.move dir (safeCurrentLevel game) |> Result.map (updateGame game)

        _ ->
            Result.Ok game


undoMove : Game -> Game
undoMove game =
    case game.state of
        Playing ->
            updateGame game (Level.undo (safeCurrentLevel game))

        _ ->
            game


undoLevel : Game -> Game
undoLevel game =
    case game.state of
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
advanceLevel game =
    case game.state of
        LevelWon ->
            case (NE.tail game.levels) of
                [] ->
                    { game
                        | state = GameOver
                        , totalMoves = game.totalMoves + (Level.moves (safeCurrentLevel game))
                        , totalPushes = game.totalPushes + (Level.pushes (safeCurrentLevel game))
                    }

                next :: rest ->
                    { game
                        | state = Playing
                        , levels = Nonempty next rest
                        , totalMoves = game.totalMoves + (Level.moves (safeCurrentLevel game))
                        , totalPushes = game.totalPushes + (Level.pushes (safeCurrentLevel game))
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
                { levelNumber = Level.number (safeCurrentLevel game)
                , totalMoves = game.totalMoves
                , totalPushes = game.totalPushes
                }


nextPlayerMood : Game -> Game
nextPlayerMood game =
    case game.state of
        Playing ->
            updateGame game (Level.nextPlayerMood (safeCurrentLevel game))

        _ ->
            game



-- HELPERS


updateGame : Game -> Level -> Game
updateGame game level =
    let
        newGameState =
            if Level.hasWon level then
                LevelWon
            else
                Playing

        newLevels =
            Nonempty level (NE.tail game.levels)
    in
        { game | levels = newLevels, state = newGameState }


safeCurrentLevel : Game -> Level
safeCurrentLevel { levels } =
    NE.head levels
