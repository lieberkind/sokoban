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
        [ div [ class "movement-info" ]
            [ div [ class "moves" ]
                [ text str1 ]
            , div [ class "pushes" ]
                [ text str2 ]
            ]
        , div [ class "game-feedback" ]
            [ text str3 ]
        ]


renderGameInfo : GameInfo -> Html msg
renderGameInfo { moves, pushes, message } =
    gameInfo
        ((toString moves) ++ " moves")
        ((toString pushes) ++ " pushes")
        (Maybe.withDefault "" message)


renderGameOverInfo : GameInfo -> Html msg
renderGameOverInfo { moves, pushes, message } =
    gameInfo
        ((toString moves) ++ " total moves")
        ((toString pushes) ++ " total pushes")
        (Maybe.withDefault "" message)
