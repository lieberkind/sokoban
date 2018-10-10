port module Main exposing (Flags, Model, clearProgress, endOfLevelKeyDecoder, getErrorMessage, inGameKeyDecoder, init, initialModel, keyToMsg, main, saveProgress, subscriptions, update, view)

import Browser as Browser
import Browser.Events as Events
import Data.Game as Game exposing (Game)
import Data.Level as Level exposing (Level)
import Data.LevelTemplate exposing (..)
import Data.Movement as Movement exposing (Direction(..), MoveError(..))
import Data.Progress exposing (Progress)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, style)
import Json.Decode as Decode
import Msg exposing (..)
import Set exposing (Set, insert, remove)
import Views.Controls
import Views.GameInfo
import Views.Header
import Views.Level
import Views.Popups



-- MAIN


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- FLAGS


type alias Flags =
    { progress : Maybe Progress
    }



-- MODEL


type alias Model =
    { keysDown : Set Int
    , game : Game
    , message : Maybe String
    , isStartingOver : Bool
    }


initialModel : Flags -> Model
initialModel flags =
    let
        game =
            flags.progress
                |> Maybe.map Game.fromProgress
                |> Maybe.withDefault Game.new

        message =
            Game.currentLevel game
                |> Maybe.map Level.number
                |> Maybe.map (\levelNumber -> "Playing level " ++ String.fromInt levelNumber ++ "...")
    in
    { keysDown = Set.empty
    , game = game
    , message = message
    , isStartingOver = False
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, Cmd.none )


port saveProgress : Progress -> Cmd msg


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
            let
                newModel =
                    case Game.move direction model.game of
                        Result.Ok game ->
                            { model | game = game, message = Nothing }

                        Result.Err err ->
                            { model | game = model.game, message = Just (getErrorMessage err) }
            in
            ( newModel, Cmd.none )

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
                        |> Maybe.map (\levelNumber -> "Playing level " ++ String.fromInt levelNumber ++ "...")

                cmd =
                    Game.toProgress newGame
                        |> Maybe.map saveProgress
                        |> Maybe.withDefault Cmd.none
            in
            ( { model | game = newGame, message = newMessage }, cmd )

        RequestStartOverConfirmation ->
            ( { model | isStartingOver = True }, Cmd.none )

        CancelStartOver ->
            ( { model | isStartingOver = False }, Cmd.none )

        ConfirmStartOver ->
            ( initialModel { progress = Nothing }, clearProgress () )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view { game, message, isStartingOver } =
    let
        level =
            Game.currentLevel game
    in
    case level of
        Just lvl ->
            div []
                [ Views.Header.renderHeader ("Level " ++ String.fromInt (Level.number lvl))
                , div [ style "position" "relative" ]
                    [ Html.map
                        (\b ->
                            if b then
                                ConfirmStartOver

                            else
                                CancelStartOver
                        )
                        (Views.Popups.confirm isStartingOver "Are you sure you want to start over? All progress will be lost.")
                    , Html.map (\_ -> AdvanceLevel) (Views.Popups.endOfLevel (Game.levelWon game) ("You completed level " ++ (Level.number lvl |> String.fromInt) ++ "\nwith " ++ (Level.moves lvl |> String.fromInt) ++ " moves \nand " ++ (Level.pushes lvl |> String.fromInt) ++ " pushes"))
                    , Views.Level.renderLevel lvl
                    , Views.GameInfo.renderGameInfo { moves = Level.moves lvl, pushes = Level.pushes lvl, message = message }
                    , Views.Controls.undoButtons { undoMove = UndoMove, undoLevel = UndoLevel }
                    , Views.Controls.arrowKeys { up = Move Up, right = Move Right, down = Move Down, left = Move Left }
                    ]
                ]

        Nothing ->
            div []
                [ Views.Header.renderHeader "Game Over"
                , div [ style "position" "relative" ]
                    [ Html.map
                        (\b ->
                            if b then
                                ConfirmStartOver

                            else
                                CancelStartOver
                        )
                        (Views.Popups.confirm isStartingOver "Are you sure you want to start over? All progress will be lost.")
                    , Views.Level.renderLevel (Level.fromTemplate gameOver)
                    , Views.GameInfo.renderGameOverInfo { moves = game.totalMoves, pushes = game.totalPushes, message = Just "Well done!" }
                    ]
                ]



-- SUBSCRIPTIONS


inGameKeyDecoder : Decode.Decoder Msg
inGameKeyDecoder =
    Decode.map keyToMsg (Decode.field "key" Decode.string)


endOfLevelKeyDecoder : Decode.Decoder Msg
endOfLevelKeyDecoder =
    Decode.map
        (\key ->
            case key of
                "Enter" ->
                    AdvanceLevel

                _ ->
                    NoOp
        )
        (Decode.field "key" Decode.string)


keyToMsg : String -> Msg
keyToMsg key =
    case key of
        "ArrowLeft" ->
            Move Left

        "ArrowRight" ->
            Move Right

        "ArrowUp" ->
            Move Up

        "ArrowDown" ->
            Move Down

        "L" ->
            UndoLevel

        "l" ->
            UndoLevel

        "M" ->
            UndoMove

        "m" ->
            UndoMove

        _ ->
            NoOp


subscriptions : Model -> Sub Msg
subscriptions { game } =
    if Game.isPlaying game then
        Sub.batch
            [ Events.onKeyDown inGameKeyDecoder
            ]

    else if Game.levelWon game then
        Events.onKeyDown endOfLevelKeyDecoder

    else
        Sub.none
