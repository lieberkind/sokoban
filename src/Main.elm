port module Main exposing
    ( Model
    , clearProgress
    , getErrorMessage
    , init
    , initialModel
    , main
    , saveProgress
    )

import Browser as Browser
import Browser.Events as Events
import Data.Game as Game exposing (Game)
import Data.Level as Level exposing (Level)
import Data.LevelTemplate exposing (..)
import Data.Movement as Movement exposing (Direction(..), MoveError(..))
import Data.Progress exposing (Progress)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, style)
import Html.Events as E
import Json.Decode as Decode
import Set exposing (Set, insert, remove)
import Views.Controls
import Views.GameInfo
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



--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------


type alias Model =
    { keysDown : Set Int
    , game : Game.Model
    , isStartingOver : Bool
    }



--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------


initialModel : Flags -> Model
initialModel flags =
    let
        game =
            flags.progress
                |> Maybe.map Game.fromProgress
                |> Maybe.withDefault Game.new

        -- Game.currentLevel game
        --     |> Maybe.map Level.number
        --     |> Maybe.map (\levelNumber -> "Playing level " ++ String.fromInt levelNumber ++ "...")
    in
    { keysDown = Set.empty
    , game = game
    , isStartingOver = False
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, Cmd.none )


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



--------------------------------------------------------------------------------
-- UPDATE
--------------------------------------------------------------------------------


type Msg
    = GameMsg Game.Msg
    | RequestStartOverConfirmation
    | ConfirmStartOver
    | CancelStartOver
    | AdvanceLevel
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GameMsg subMsg ->
            ( { model | game = Game.update subMsg model.game }, Cmd.none )

        AdvanceLevel ->
            let
                newGame =
                    Game.advanceLevel model.game

                cmd =
                    Game.toProgress newGame
                        |> Maybe.map saveProgress
                        |> Maybe.withDefault Cmd.none
            in
            ( { model | game = newGame }, cmd )

        RequestStartOverConfirmation ->
            ( { model | isStartingOver = True }, Cmd.none )

        CancelStartOver ->
            ( { model | isStartingOver = False }, Cmd.none )

        ConfirmStartOver ->
            ( initialModel { progress = Nothing }, clearProgress () )

        _ ->
            ( model, Cmd.none )



--------------------------------------------------------------------------------
-- VIEW
--------------------------------------------------------------------------------


view : Model -> Html Msg
view model =
    div []
        [ viewHeader model
        , div
            [ style "position" "relative" ]
            [ viewConfirmDialog model.isStartingOver "Are you sure you want to start over? All progress will be lost."
            , viewEndOfLevelDialog model
            , Html.map GameMsg (Game.view model.game)
            ]
        ]


viewConfirmDialog : Bool -> String -> Html Msg
viewConfirmDialog visible question =
    div
        [ classList
            [ ( "popup", True )
            , ( "visible", visible )
            ]
        ]
        [ p [ class "preserve-line-breaks" ] [ text question ]
        , button
            [ class "keyboard-button cancel", E.onClick ConfirmStartOver ]
            [ text "Cancel" ]
        , button
            [ class "keyboard-button confirm", E.onClick CancelStartOver ]
            [ text "OK" ]
        ]


viewEndOfLevelDialog : Model -> Html Msg
viewEndOfLevelDialog model =
    div
        [ classList
            [ ( "popup", True )
            , ( "visible", Game.levelWon model.game )
            ]
        ]
        [ p
            [ class "preserve-line-breaks" ]
            -- [ text ("You completed level " ++ (Level.number lvl |> String.fromInt) ++ "\nwith " ++ (Level.moves lvl |> String.fromInt) ++ " moves \nand " ++ (Level.pushes lvl |> String.fromInt) ++ " pushes")) ]
            [ text "You completed a level" ]
        , button
            [ class "keyboard-button dismiss-popup", E.onClick AdvanceLevel ]
            [ text "OK" ]
        ]



-- let
--     level =
--         Game.currentLevel game
-- in
-- case level of
--     Just lvl ->
--         div []
--             [ Views.Header.renderHeader ("Level " ++ String.fromInt (Level.number lvl))
--             , div [ style "position" "relative" ]
--                 [ Html.map
--                     (\b ->
--                         if b then
--                             ConfirmStartOver
--
--                         else
--                             CancelStartOver
--                     )
--                     (Views.Popups.confirm isStartingOver "Are you sure you want to start over? All progress will be lost.")
--                 , Html.map (\_ -> AdvanceLevel) (Views.Popups.endOfLevel (Game.levelWon game) ("You completed level " ++ (Level.number lvl |> String.fromInt) ++ "\nwith " ++ (Level.moves lvl |> String.fromInt) ++ " moves \nand " ++ (Level.pushes lvl |> String.fromInt) ++ " pushes"))
--                 , Html.map GameMsg (Game.view game)
--                 , Views.GameInfo.renderGameInfo { moves = Level.moves lvl, pushes = Level.pushes lvl, message = message }
--                 , Views.Controls.undoButtons { undoMove = UndoMove, undoLevel = UndoLevel }
--                 , Views.Controls.arrowKeys { up = Move Up, right = Move Right, down = Move Down, left = Move Left }
--                 ]
--             ]
--
--     Nothing ->
--         div []
--             [ Views.Header.renderHeader "Game Over"
--             , div [ style "position" "relative" ]
--                 [ Html.map
--                     (\b ->
--                         if b then
--                             ConfirmStartOver
--
--                         else
--                             CancelStartOver
--                     )
--                     (Views.Popups.confirm isStartingOver "Are you sure you want to start over? All progress will be lost.")
--                 , Html.map (GameMsg Game.view game)
--                 , Views.GameInfo.renderGameOverInfo
--                     { moves = Game.getTotalMoves game
--                     , pushes = Game.getTotalPushes game
--                     , message = Just "Well done!"
--                     }
--                 ]
--             ]


viewHeader : Model -> Html Msg
viewHeader model =
    let
        headerString =
            case Game.currentLevel model.game of
                Just level ->
                    "Playing level " ++ String.fromInt level.number

                Nothing ->
                    "Game Over"
    in
    div []
        [ h1 [ class "title" ] [ text "Sokoban" ]
        , div [ class "level-status" ]
            [ span [ class "level" ] [ text headerString ]
            , span [] [ text " - " ]
            , a [ href "#", class "start-over", E.onClick RequestStartOverConfirmation ] [ text "Start over" ]
            ]
        ]



--------------------------------------------------------------------------------
-- SUBSCRIPTIONS
--------------------------------------------------------------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map GameMsg (Game.subscriptions model.game)



--------------------------------------------------------------------------------
-- PORTS
--------------------------------------------------------------------------------


port saveProgress : Progress -> Cmd msg


port clearProgress : () -> Cmd msg
