module Views.GameElement exposing (renderGameElement)

import Data.GameElement exposing (..)
import Html exposing (Html, div)
import Html.Attributes exposing (class, id)


renderGameElement : GameElement -> Html msg
renderGameElement obj =
    let
        crate =
            div [ class "game-element crate" ] []

        player =
            div [ class "soko", id "soko" ] []
    in
    case obj of
        Block ->
            div [ class "game-element block" ] []

        FreeSpace Path ->
            div [ class "game-element path" ] []

        FreeSpace GoalField ->
            div [ class "game-element goal-field" ] []

        OccupiedSpace Path Crate ->
            div [ class "game-element path" ] [ crate ]

        OccupiedSpace Path Player ->
            div [ class "game-element path" ] [ player ]

        OccupiedSpace GoalField Crate ->
            div [ class "game-element goal-field" ] [ crate ]

        OccupiedSpace GoalField Player ->
            div [ class "game-element goal-field" ] [ player ]
