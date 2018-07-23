module Views.Level exposing (renderLevel)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (class)
import Data.GameElement exposing (GameElement)
import Views.GameElement
import Data.Level as Level exposing (Level)


renderLevel : Level -> Html msg
renderLevel level =
    printGrid (Level.grid level)



-- HELPERS


printGrid : Array GameElement -> Html msg
printGrid grid =
    div
        [ class "grid" ]
        (Array.map Views.GameElement.renderGameElement grid |> Array.toList)
