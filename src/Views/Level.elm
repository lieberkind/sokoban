module Views.Level exposing (renderLevel)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (style)
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
        [ style [ ( "margin", "0 auto" ), ( "width", "304px" ), ( "overflow", "hidden" ) ] ]
        (Array.map Views.GameElement.renderGameElement grid |> Array.toList)
