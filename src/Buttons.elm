port module UndoButtons exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Keyboard exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type Model
    = None


model : Model
model =
    None


init : ( Model, Cmd Msg )
init =
    ( None, Cmd.none )



-- UPDATE


type Direction
    = Left
    | Right
    | Up
    | Down


type Msg
    = UndoMove
    | UndoLevel
    | Move Direction
    | NoOp


port undo : String -> Cmd msg


toJSMsg : Msg -> String
toJSMsg msg =
    case msg of
        UndoMove ->
            "UNDO_MOVE"

        UndoLevel ->
            "UNDO_LEVEL"

        NoOp ->
            "NOOP"

        Move direction ->
            case direction of
                Left ->
                    "MOVE_LEFT"

                Up ->
                    "MOVE_UP"

                Right ->
                    "MOVE_RIGHT"

                Down ->
                    "MOVE_DOWN"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        _ ->
            ( model, undo (toJSMsg msg) )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [ class "undo-buttons" ]
            [ button [ class "keyboard-button undo-move", onClick UndoMove ] [ text "Undo Move (M)" ]
            , button [ class "keyboard-button undo-level", onClick UndoLevel ] [ text "Undo Level (L)" ]
            ]
        , div [ class "arrow-buttons" ]
            [ div [ class "top-row" ]
                [ button [ class "keyboard-button arrow-button up-arrow", onClick (Move Up) ] [ text "▲" ] ]
            , div [ class "bottom-row" ]
                [ button [ class "keyboard-button arrow-button left-arrow", onClick (Move Left) ] [ text "◀" ]
                , button [ class "keyboard-button arrow-button down-arrow", onClick (Move Down) ] [ text "▼" ]
                , button [ class "keyboard-button arrow-button right-arrow", onClick (Move Right) ] [ text "▶" ]
                ]
            ]
        ]



-- SUBSCRIPTIONS


keycodeToCmd : KeyCode -> Msg
keycodeToCmd code =
    case code of
        76 ->
            UndoLevel

        77 ->
            UndoMove

        37 ->
            Move Left

        38 ->
            Move Up

        39 ->
            Move Right

        40 ->
            Move Down

        _ ->
            NoOp


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.downs keycodeToCmd
