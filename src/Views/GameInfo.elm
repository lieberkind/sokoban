module Views.GameInfo exposing (renderGameInfo, renderGameOverInfo)

import Html exposing (..)
import Html.Attributes exposing (class)


type alias GameInfo =
    { moves : Int
    , pushes : Int
    , message : Maybe String
    }


gameInfo : String -> String -> String -> Html msg
gameInfo str1 str2 str3 =
    div [ class "game-info" ]
        [ div [ class "moves" ]
            [ text str1 ]
        , div [ class "pushes" ]
            [ text str2 ]
        , div [ class "feedback" ]
            [ text str3 ]
        ]


renderGameInfo : GameInfo -> Html msg
renderGameInfo { moves, pushes, message } =
    gameInfo
        ((String.fromInt moves) ++ " moves")
        ((String.fromInt pushes) ++ " pushes")
        (Maybe.withDefault "" message)


renderGameOverInfo : GameInfo -> Html msg
renderGameOverInfo { moves, pushes, message } =
    gameInfo
        ((String.fromInt moves) ++ " total moves")
        ((String.fromInt pushes) ++ " total pushes")
        (Maybe.withDefault "" message)
