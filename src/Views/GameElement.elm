module Views.GameElement exposing (..)

import Data.GameElement exposing (..)
import Html exposing (Html, Attribute, div)
import Html.Attributes exposing (style, class, id)


block : Html msg
block =
    div
        [ class "game-element block" ]
        []


player : Html msg
player =
    div
        [ class "soko", id "soko" ]
        []


crate : Html msg
crate =
    div
        [ class "game-element crate" ]
        []


renderSpace : Occupyable r -> Html msg
renderSpace { kind, occupant } =
    let
        renderOccupant : Maybe MovingObject -> Html msg
        renderOccupant o =
            (Maybe.map renderMovingObject o |> Maybe.withDefault (div [] []))
    in
        case kind of
            GoalField ->
                div
                    [ class "game-element goal-field" ]
                    [ renderOccupant occupant ]

            Path ->
                div
                    [ class "game-element path" ]
                    [ renderOccupant occupant ]


renderMovingObject : MovingObject -> Html msg
renderMovingObject obj =
    case obj of
        Player ->
            player

        Crate ->
            crate


renderGameElement : GameElement -> Html msg
renderGameElement obj =
    case obj of
        Space s ->
            renderSpace s

        Block ->
            block



-- HELPERS
