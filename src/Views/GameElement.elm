module Views.GameElement exposing (..)

import Data.GameElement exposing (..)
import Html exposing (Html, Attribute, div)
import Html.Attributes exposing (style, class)


block : Html msg
block =
    div
        [ withDefaults
            [ ( "background-image", "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAaklEQVRYR+3XOQ7AIAxE0XD/4yQVS8HJjIRkCqdIBVPkUyMYP7mZZGZ2Cc5T2/w1/S6AT95z1wh8BvALu9bCJ/f3XztAAAQQQAABBBBAAAEEEJAJxMKwqxfEd1cvkAW4S53tODaWYwLqAAMAoAJYuhkgzQAAAABJRU5ErkJgggAA')" )
            ]
        ]
        []


player : Html msg
player =
    div
        [ withDefaults []
        , class "soko"
        ]
        []


crate : Html msg
crate =
    div
        [ withDefaults
            [ ( "background-image", "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAwklEQVRYR+2W2w2AIAwAYThmUSdSZ2E4jMQmyFtsLTH4SaS9XqBFCuZPMucXNQCGCNLm7hrAVr4KhSJgEdqPUzTABkCSWO2bNaCnGUwkDbABkJx2qBzKzhnoA8AgYcjrgj820C8AtKxKQ/gG2ABSzbpgAs8AG0DNmDovd8LEewPsALeOHRmI/z8Dw8AwgGzAfwfEwtuLFUxDpE7YDtD4JoZO6GyPluIuxg18DdCYL7ct29QDA5wABLnLIWtnXjlS4x8HfjeSIYxtab0AAAAASUVORK5CYIIA')" )
            ]
        ]
        []


renderSpace : Occupyable r -> Html msg
renderSpace { kind, occupant } =
    let
        renderOccupant : Maybe MovingObject -> Html msg
        renderOccupant o =
            (Maybe.map renderMovingObject o |> Maybe.withDefault (div [] []))
    in
        case kind of
            GoalField ->
                div
                    [ withDefaults
                        [ ( "background-image", "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAYklEQVRYR+3VywoAIAhEUf3/jzYi2rjTgR5w3UvjIdTNLOxiOQEQQAABBL4ViFgnxH1u8361b8EzAfLsVRFZ4HiATa8+vPvLAtcD5MnVz1gWeC5AfwOsTlmAAAgggAACqsAA1gU4AQHGir0AAAAASUVORK5CYIIA')" )
                        ]
                    ]
                    [ renderOccupant occupant ]

            Path ->
                div
                    [ withDefaults
                        [ ( "background-image", "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAXklEQVRYR+3WQQoAIAhEUb3/oW0RbtzZQBb89tL0ECa3iLDB4wRAAAEEEPhXwH03iFgl513wTIDapE0RXeB6gKQXL87xvsB4gPpycRn7As8FEP+TugABEEAAAQREgQWkNW/BkvP04AAAAABJRU5ErkJgggAA')" )
                        ]
                    ]
                    [ renderOccupant occupant ]


renderMovingObject : MovingObject -> Html msg
renderMovingObject obj =
    case obj of
        Player ->
            player

        Crate ->
            crate


renderGameElement : GameElement -> Html msg
renderGameElement obj =
    case obj of
        Space s ->
            renderSpace s

        Block ->
            block



-- HELPERS


withDefaults : List ( String, String ) -> Attribute msg
withDefaults attrs =
    style
        (List.append
            [ ( "background-size", "16px 16px" )
            , ( "background-repeat", "no-repeat" )
            , ( "width", "16px" )
            , ( "height", "16px" )
            , ( "float", "left" )
            ]
            attrs
        )
