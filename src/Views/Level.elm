module Views.Level exposing (renderLevel)

import Html exposing (..)
import Html.Attributes exposing (style)
import Matrix exposing (Matrix)
import Data.GameElement exposing (GameElement)
import Views.GameElement
import Data.Level as Level exposing (Level)


renderLevel : Level -> Html msg
renderLevel level =
    printGrid (Level.grid level)



-- HELPERS


printGrid : Matrix.Matrix GameElement -> Html msg
printGrid grid =
    let
        printRow : List GameElement -> Html msg
        printRow elements =
            div
                [ style [ ( "overflow", "hidden" ) ] ]
                (List.map Views.GameElement.renderGameElement elements)
    in
        div
            [ style [ ( "margin", "0 auto" ), ( "width", "304px" ) ] ]
            (List.map printRow (Matrix.toList grid))
