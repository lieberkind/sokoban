module Views.Popups exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Msg exposing (Msg(AdvanceLevel))


type alias LevelStats =
    { levelNumber : Int
    , moves : Int
    , pushes : Int
    }


endOfLevel : Bool -> LevelStats -> Html Msg
endOfLevel visible { levelNumber, moves, pushes } =
    div
        [ classList
            [ ( "popup", True )
            , ( "visible", visible )
            ]
        ]
        [ p
            []
            [ text ("You completed level " ++ (toString levelNumber))
            , br [] []
            , text ("with " ++ (toString moves) ++ " moves")
            , br [] []
            , text ("and " ++ (toString pushes) ++ " pushes")
            ]
        , button
            [ class "keyboard-button dismiss-popup" ]
            [ text "OK" ]
        , button
            [ class "keyboard-button dismiss-popup", onClick AdvanceLevel ]
            [ text "OK" ]
        ]
