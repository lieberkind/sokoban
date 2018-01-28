port module Moves exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)

main : Program Never Model Msg
main =
  Html.program 
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model = Int

model : Model
model =
  0

init : (Model, Cmd Msg)
init =
  (0, Cmd.none)


-- UPDATE

type Msg = Reset | Move | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Reset ->
            (0, Cmd.none)

        Move ->
            (model + 1, Cmd.none)
        
        NoOp ->
            (model, Cmd.none)


-- VIEW

view : Model -> Html Msg
view model =
  div [class "moves"] [text (toString model ++ " Moves")]


-- SUBSCRIPTIONS

port move : (String -> msg) -> Sub msg

toMsg : String -> Msg
toMsg str =
    case str of
        "Reset" ->
            Reset
        
        "Move" ->
            Move
        
        _ ->
            NoOp

subscriptions : Model -> Sub Msg
subscriptions model = move toMsg