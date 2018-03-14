module Views.Header exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Msg exposing (..)


renderHeader : Int -> Html Msg
renderHeader levelNumber =
    div []
        [ h1 [ class "title" ] [ text "Sokoban" ]
        , div [ class "level-status" ]
            [ span [ class "level" ] [ text ("Level " ++ toString levelNumber) ]
            , span [] [ text " - " ]
            , a [ href "#", class "start-over", onClick RequestStartOverConfirmation ] [ text "Start over" ]
            ]
        ]
