port module Main exposing (..)

import Data.Game as Game exposing (Game, Progress)
import Data.Level as Level exposing (Level)
import Data.Movement as Movement exposing (Direction(..), MoveError(..))
import Html exposing (..)
import Keyboard exposing (..)
import Msg exposing (..)
import Set exposing (Set, insert, remove)
import Views exposing (renderApp)


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
                |> Maybe.map (\levelNumber -> "Playing level " ++ toString levelNumber ++ "...")
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
                        |> Maybe.map (\levelNumber -> "Playing level " ++ toString levelNumber ++ "...")

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


view : Model -> Html Msg
view model =
    renderApp model.game model.message model.isStartingOver



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
    if Game.isPlaying game then
        Sub.batch
            [ Keyboard.downs keyCodeToMsg
            , Keyboard.ups keyUpToMsg
            ]
    else if Game.levelWon game then
        Keyboard.downs
            (\keyCode ->
                if keyCode == 13 then
                    AdvanceLevel
                else
                    NoOp
            )
    else
        Sub.none
