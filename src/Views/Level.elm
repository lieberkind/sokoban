module Views.Level exposing (renderLevel)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (class)
import Views.GameElement
import Data.Level as Level exposing (Level)


renderLevel : Level -> Html msg
renderLevel level =
    div
        [ class "grid" ]
        (Level.getGrid level
            |> Array.toList
            |> List.map Views.GameElement.renderGameElement
        )
