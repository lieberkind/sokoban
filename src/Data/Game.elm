module Data.Game
    exposing
        ( Game
        , advanceLevel
        , initialise
        , isOver
        , move
        , reset
        , undoLevel
        , undoMove
        )

import SelectList exposing (SelectList, Position(..))
import Data.Level as Level exposing (..)
import Data.LevelTemplate exposing (LevelTemplate)
import Data.Movement exposing (Direction, MoveError(..))


type Game
    = Playing (SelectList Level)
    | LevelWon (SelectList Level)
    | GameOver (SelectList Level)


initialise : SelectList LevelTemplate -> Game
initialise =
    Playing << SelectList.map Level.fromTemplate


move : Direction -> Game -> Result MoveError Game
move dir game =
    case game of
        Playing lvls ->
            let
                lvl =
                    SelectList.selected lvls
            in
                case Level.move dir lvl of
                    _ ->
                        Result.Ok game

                    Result.Err err ->
                        Result.Err err

        LevelWon _ ->
            Result.Ok game

        GameOver _ ->
            Result.Ok game


reset : Game -> Game
reset game =
    case game of
        Playing lvls ->
            Playing (resetSelectList lvls)

        LevelWon lvls ->
            Playing (resetSelectList lvls)

        GameOver lvls ->
            Playing (resetSelectList lvls)


undoMove : Game -> Game
undoMove game =
    case game of
        Playing lvls ->
            Playing (updateSelected Level.undo lvls)

        LevelWon lvls ->
            game

        GameOver _ ->
            game


undoLevel : Game -> Game
undoLevel game =
    case game of
        Playing lvls ->
            Playing (updateSelected Level.reset lvls)

        LevelWon lvls ->
            Playing (updateSelected Level.reset lvls)

        GameOver _ ->
            game


advanceLevel : Game -> Game
advanceLevel game =
    game



-- HELPERS


isOver : Game -> Bool
isOver game =
    False


resetSelectList : SelectList a -> SelectList a
resetSelectList ls =
    case (SelectList.before ls) of
        [] ->
            SelectList.fromLists [] (SelectList.selected ls) (SelectList.after ls)

        x :: xs ->
            let
                rest =
                    xs
                        |> List.append [ SelectList.selected ls ]
                        |> List.append (SelectList.after ls)
            in
                SelectList.fromLists [] x rest


updateSelected : (a -> a) -> SelectList a -> SelectList a
updateSelected fn =
    SelectList.mapBy
        (\pos a ->
            if pos == Selected then
                fn a
            else
                a
        )
