module Data.Game
    exposing
        ( Game(..)
        , advanceLevel
        , currentLevel
        , initialise
        , isOver
        , levelWon
        , move
        , undoLevel
        , undoMove
        )

import Data.Level as Level exposing (..)
import Data.Movement exposing (Direction, MoveError(..))
import Data.LevelTemplate exposing (LevelTemplate)


type Game
    = Playing ( Level, List Level )
    | LevelWon ( Level, Level, List Level )
    | GameOver Level


initialise : LevelTemplate -> List LevelTemplate -> Game
initialise first rest =
    Playing ( Level.fromTemplate first, List.map Level.fromTemplate rest )


move : Direction -> Game -> Result MoveError Game
move dir game =
    case game of
        Playing ( lvl, lvls ) ->
            Level.move dir lvl |> Result.map (updateLevel lvls)

        _ ->
            Result.Ok game



{- This needs a better name. Basically, it takes a level, and the rest of the
   levels, and returns a game state based on those.
-}


updateLevel : List Level -> Level -> Game
updateLevel rest lvl =
    if Level.hasWon lvl then
        case rest of
            [] ->
                GameOver lvl

            next :: rest ->
                LevelWon ( lvl, next, rest )
    else
        Playing ( lvl, rest )


undoMove : Game -> Game
undoMove game =
    case game of
        Playing ( current, rest ) ->
            Playing ( Level.undo current, rest )

        _ ->
            game


undoLevel : Game -> Game
undoLevel game =
    case game of
        Playing ( current, rest ) ->
            Playing ( Level.reset current, rest )

        LevelWon ( current, next, rest ) ->
            Playing ( Level.reset current, next :: rest )

        GameOver _ ->
            game


currentLevel : Game -> Level
currentLevel game =
    case game of
        Playing ( current, _ ) ->
            current

        LevelWon ( current, _, _ ) ->
            current

        GameOver current ->
            current


advanceLevel : Game -> Game
advanceLevel game =
    case game of
        LevelWon ( current, next, rest ) ->
            Playing ( next, rest )

        _ ->
            game


levelWon : Game -> Bool
levelWon game =
    case game of
        LevelWon _ ->
            True

        _ ->
            False



-- HELPERS


isOver : Game -> Bool
isOver game =
    False
