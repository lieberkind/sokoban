module Views.Header exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Msg exposing (..)


renderHeader : String -> Html Msg
renderHeader str =
    div []
        [ h1 [ class "title" ] [ text "Sokoban" ]
        , div [ class "level-status" ]
            [ span [ class "level" ] [ text str ]
            , span [] [ text " - " ]
            , a [ href "#", class "start-over", onClick RequestStartOverConfirmation ] [ text "Start over" ]
            ]
        ]
