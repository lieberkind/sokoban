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

type Model = None

model : Model
model = None

init : (Model, Cmd Msg)
init =
  (None, Cmd.none)


-- UPDATE

type Msg = UndoMove | UndoLevel | NoOp 


port undo : String -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UndoMove ->
            (model, undo "move")
        
        UndoLevel ->
            (model, undo "level")
        
        NoOp ->
            (model, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
  div [ class "undo-buttons" ]
    [ button [ class "keyboard-button undo-move", onClick UndoMove ] [ text "Undo Move (M)" ]
    , button [ class "keyboard-button undo-level", onClick UndoLevel ] [ text "Undo Level (L)" ]
    ]


-- SUBSCRIPTIONS

keycodeToCmd : KeyCode -> Msg
keycodeToCmd code =
    case code of
        76 ->
            UndoLevel

        77 ->
            UndoMove

        _ -> NoOp


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.downs keycodeToCmd