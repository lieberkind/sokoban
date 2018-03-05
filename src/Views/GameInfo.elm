module Views.GameInfo exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)


type alias GameInfo =
    { moves : Int
    , pushes : Int
    , message : Maybe String
    }


renderGameInfo : GameInfo -> Html msg
renderGameInfo { moves, pushes, message } =
    div [ class "game-info" ]
        [ div [ class "movement-info" ]
            [ div [ class "moves" ]
                [ (toString moves) ++ " moves" |> text ]
            , div [ class "pushes" ]
                [ (toString pushes) ++ " pushes" |> text ]
            ]
        , div [ class "game-feedback" ]
            [ Maybe.withDefault "" message |> text ]
        ]
