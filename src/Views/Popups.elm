module Views.Popups exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)


type alias LevelStats =
    { levelNumber : Int
    , moves : Int
    , pushes : Int
    }


endOfLevel : Bool -> String -> Html ()
endOfLevel visible str =
    div
        [ classList
            [ ( "popup", True )
            , ( "visible", visible )
            ]
        ]
        [ p
            [ class "preserve-line-breaks" ]
            [ text str ]
        , button
            [ class "keyboard-button dismiss-popup", onClick () ]
            [ text "OK" ]
        ]


confirm : Bool -> String -> Html Bool
confirm visible question =
    div
        [ classList
            [ ( "popup", True )
            , ( "visible", visible )
            ]
        ]
        [ p [ class "preserve-line-breaks" ] [ text question ]
        , button
            [ class "keyboard-button cancel", onClick False ]
            [ text "Cancel" ]
        , button
            [ class "keyboard-button confirm", onClick True ]
            [ text "OK" ]
        ]
