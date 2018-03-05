module Views.Controls exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onMouseDown)


undoButtons : { undoMove : msg, undoLevel : msg } -> Html msg
undoButtons { undoMove, undoLevel } =
    div [ class "undo-buttons" ]
        [ keyboardButton [ "undo-move" ] undoMove "Undo Move (M)"
        , keyboardButton [ "undo-level" ] undoLevel "Undo Level (L)"
        ]


arrowKeys : { up : msg, right : msg, down : msg, left : msg } -> Html msg
arrowKeys { up, right, down, left } =
    div [ class "arrow-buttons" ]
        [ div [ class "top-row" ]
            [ keyboardButton [ "arrow-button", "up-arrow" ] up "▲" ]
        , div [ class "bottom-row" ]
            [ keyboardButton [ "arrow-button", "up-arrow" ] left "◀"
            , keyboardButton [ "arrow-button", "down-arrow" ] down "▼"
            , keyboardButton [ "arrow-button", "right-arrow" ] right "▶"
            ]
        ]



-- HELPERS


keyboardButton : List String -> msg -> String -> Html msg
keyboardButton classes msg label =
    let
        defaultClasses =
            [ ( "keyboard-button", True ) ]

        customClasses =
            (List.map (\className -> ( className, True )) classes)
    in
        button
            [ classList (List.append defaultClasses customClasses)
            , onMouseDown msg
            ]
            [ text label ]
