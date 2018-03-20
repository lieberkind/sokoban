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
import Data.LevelTemplate exposing (level0, level1, gameOver)
import Data.Movement as Movement exposing (Direction(..), MoveError(..))
import Data.Game as Game exposing (Game)
import Data.Progress exposing (Progress)
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
            Maybe.withDefault (Game.initialise level0 [ level1 ]) <|
                case flags.progress of
                    Just progress ->
                        Game.initialiseFromSaved progress [ level0, level1 ]

                    _ ->
                        Nothing

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
view { game, message, isStartingOver } =
    let
        level =
            Game.currentLevel game
    in
        case level of
            Just lvl ->
                div []
                    [ Views.Header.renderHeader ("Level " ++ toString (Level.number lvl))
                    , div [ style [ ( "position", "relative" ) ] ]
                        [ Html.map
                            (\b ->
                                if b then
                                    ConfirmStartOver
                                else
                                    CancelStartOver
                            )
                            (Views.Popups.confirm isStartingOver "Are you sure you want to start over? All progress will be lost.")
                        , Html.map (\_ -> AdvanceLevel) (Views.Popups.endOfLevel (Game.levelWon game) ("You completed level " ++ (Level.number lvl |> toString) ++ "\nwith " ++ (Level.moves lvl |> toString) ++ " moves \nand " ++ (Level.pushes lvl |> toString) ++ " pushes"))
                        , Views.Level.renderLevel lvl
                        , Views.GameInfo.renderGameInfo { moves = Level.moves lvl, pushes = Level.pushes lvl, message = message }
                        , Views.Controls.undoButtons { undoMove = UndoMove, undoLevel = UndoLevel }
                        , Views.Controls.arrowKeys { up = Move Up, right = Move Right, down = Move Down, left = Move Left }
                        ]
                    ]

            Nothing ->
                div []
                    [ Views.Header.renderHeader "Game Over"
                    , div [ style [ ( "position", "relative" ) ] ]
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

                        -- , Views.Controls.undoButtons { undoMove = UndoMove, undoLevel = UndoLevel }
                        -- , Views.Controls.arrowKeys { up = Move Up, right = Move Right, down = Move Down, left = Move Left }
                        ]
                    ]



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
