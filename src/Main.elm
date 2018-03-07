port module Main exposing (..)

import List
import Set exposing (Set, insert, remove)
import Html exposing (..)
import Html.Attributes exposing (class, classList, style, attribute, href)
import Html.Events exposing (onMouseDown, onMouseUp, onClick)
import Keyboard exposing (..)
import Data.Level as Level exposing (Level)
import Views.Controls
import Views.Level
import Views.GameInfo
import Views.Popups
import Views.Header
import Data.LevelTemplate exposing (level0, level1)
import Data.Movement as Movement exposing (Direction(..), MoveError(..))
import Data.Game as Game exposing (Game(..))
import Msg exposing (..)


-- MAIN


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- FLAGS


type alias Flags =
    { startAtLevel : Maybe Int
    }



-- MODEL


type alias Model =
    { keysDown : Set Int
    , game : Game
    , message : Maybe String
    }


initialModel : Model
initialModel =
    let
        game =
            Game.initialiseFromLevelNumber -1 [ level1, level0 ]

        message =
            Game.currentLevel game
                |> Maybe.map Level.number
                |> Maybe.map (\levelNumber -> "Playing level " ++ toString levelNumber ++ "...")
    in
        { keysDown = Set.empty
        , game = game
        , message = message
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        initialiseLevels =
            flags.startAtLevel
                |> Maybe.map Game.initialiseFromLevelNumber
                |> Maybe.withDefault Game.initialise

        game =
            initialiseLevels [ level1, level0 ]

        message =
            Game.currentLevel game
                |> Maybe.map Level.number
                |> Maybe.map (\levelNumber -> "Playing level " ++ toString levelNumber ++ "...")

        model =
            { keysDown = Set.empty
            , game = game
            , message = message
            }
    in
        ( model, Cmd.none )


port saveProgress : Int -> Cmd msg


port clearProgress : () -> Cmd msg


getErrorMessage : MoveError -> String
getErrorMessage err =
    case err of
        Impossible ->
            "This should not happen..."

        OutOfBounds ->
            "How did you get here???"

        BlockedByCrate ->
            "{ooph...grumble}"

        BlockedByBlock ->
            "Ouch!"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Move direction ->
            case Game.move direction model.game of
                Result.Ok game ->
                    let
                        newModel =
                            { model
                                | game = game
                                , message = Nothing
                            }
                    in
                        ( newModel, Cmd.none )

                Result.Err err ->
                    ( { model | message = Just (getErrorMessage err) }
                    , Cmd.none
                    )

        UndoMove ->
            ( { model | game = Game.undoMove model.game, message = Just "Whew! That was close!" }, Cmd.none )

        UndoLevel ->
            ( { model | game = Game.undoLevel model.game, message = Just "Not so easy, is it?" }, Cmd.none )

        AdvanceLevel ->
            let
                newGame =
                    Game.advanceLevel model.game

                newMessage =
                    Game.currentLevel newGame
                        |> Maybe.map Level.number
                        |> Maybe.map (\levelNumber -> "Playing level " ++ toString levelNumber ++ "...")

                cmd =
                    Game.currentLevel newGame
                        |> Maybe.map Level.number
                        |> Maybe.map saveProgress
                        |> Maybe.withDefault Cmd.none
            in
                ( { model | game = newGame, message = newMessage }, cmd )

        StartOver ->
            ( initialModel, clearProgress () )

        _ ->
            ( model, Cmd.none )



-- VIEW


keyboardButton : List String -> Msg -> String -> Html Msg
keyboardButton classes msg label =
    let
        defaultClasses =
            [ ( "keyboard-button", True ) ]

        customClasses =
            (List.map (\className -> ( className, True )) classes)
    in
        button
            [ classList (List.append defaultClasses customClasses)
            , onMouseDown msg
            ]
            [ text label ]


view : Model -> Html Msg
view { game, message } =
    let
        level =
            Game.currentLevel game
    in
        case level of
            Just lvl ->
                div []
                    [ Views.Header.renderHeader (Level.number lvl)
                    , div [ style [ ( "position", "relative" ) ] ]
                        [ Views.Popups.endOfLevel (Game.levelWon game) { levelNumber = Level.number lvl, moves = Level.moves lvl, pushes = Level.pushes lvl }
                        , Views.Level.renderLevel lvl
                        , Views.GameInfo.renderGameInfo { moves = Level.moves lvl, pushes = Level.pushes lvl, message = message }
                        , Views.Controls.undoButtons { undoMove = UndoMove, undoLevel = UndoLevel }
                        , Views.Controls.arrowKeys { up = Move Up, right = Move Right, down = Move Down, left = Move Left }
                        ]
                    ]

            Nothing ->
                text "Game over. Well done."



-- SUBSCRIPTIONS


keyCodeToMsg : KeyCode -> Msg
keyCodeToMsg keyCode =
    case keyCode of
        37 ->
            Move Left

        38 ->
            Move Up

        39 ->
            Move Right

        40 ->
            Move Down

        76 ->
            UndoLevel

        77 ->
            UndoMove

        _ ->
            NoOp


keyUpToMsg : KeyCode -> Msg
keyUpToMsg keyCode =
    NoOp


subscriptions : Model -> Sub Msg
subscriptions { game } =
    case game of
        Playing _ ->
            Sub.batch
                [ Keyboard.downs keyCodeToMsg
                , Keyboard.ups keyUpToMsg
                ]

        LevelWon _ ->
            Keyboard.downs
                (\keyCode ->
                    if keyCode == 13 then
                        AdvanceLevel
                    else
                        NoOp
                )

        _ ->
            Sub.none
