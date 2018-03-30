module Views exposing (..)

import Data.GameElement exposing (..)
import Data.Level as Level exposing (Level)
import Data.Game as Game exposing (Game)
import Data.Movement exposing (Direction(..))
import Data.LevelTemplate exposing (gameOver)
import Data.Cyclic as Cyclic exposing (Cyclic, current)
import Data.PlayerSprite exposing (PlayerSprite(..))
import Msg exposing (..)
import Html exposing (..)
import Html.Attributes exposing (id, class, style, classList, href)
import Html.Events exposing (onMouseDown, onClick)
import Matrix exposing (Matrix)


-- GameElement


player : PlayerMood -> Html msg
player currentPlayerSprite =
    let
        playerClass =
            currentPlayerSprite |> toString |> String.toLower
    in
        div
            [ withDefaults []
            , class ("soko " ++ playerClass)
            , id "soko"
            ]
            []


block : Html msg
block =
    div
        [ withDefaults
            [ ( "background-image", "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAaklEQVRYR+3XOQ7AIAxE0XD/4yQVS8HJjIRkCqdIBVPkUyMYP7mZZGZ2Cc5T2/w1/S6AT95z1wh8BvALu9bCJ/f3XztAAAQQQAABBBBAAAEEEJAJxMKwqxfEd1cvkAW4S53tODaWYwLqAAMAoAJYuhkgzQAAAABJRU5ErkJgggAA')" )
            ]
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


renderOccupyable : Occupyable -> Html msg
renderOccupyable { kind, occupant } =
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


renderOccupant : Occupant -> Html msg
renderOccupant occupant =
    case occupant of
        Player moods ->
            player (Cyclic.current moods)

        Crate ->
            crate

        None ->
            div [] []


renderGameElement : GameElement -> Html msg
renderGameElement elm =
    case elm of
        Space occupyable ->
            renderOccupyable occupyable

        Block ->
            block


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



-- Controls


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



-- Level


renderLevel : Level -> Html msg
renderLevel level =
    let
        grid =
            Level.grid level

        printRow : List GameElement -> Html msg
        printRow elements =
            div
                [ style [ ( "overflow", "hidden" ) ] ]
                (List.map renderGameElement elements)
    in
        div
            [ style [ ( "margin", "0 auto" ), ( "width", "304px" ) ] ]
            (List.map printRow (Matrix.toList grid))



-- printGrid (Level.grid level)
-- printGrid : Matrix GameElement -> Html msg
-- printGrid grid =
--     let
--         printRow : List GameElement -> Html msg
--         printRow elements =
--             div
--                 [ style [ ( "overflow", "hidden" ) ] ]
--                 (List.map renderGameElement elements)
--     in
--         div
--             [ style [ ( "margin", "0 auto" ), ( "width", "304px" ) ] ]
--             (List.map printRow (Matrix.toList grid))
-- Header


renderHeader : String -> Html Msg
renderHeader str =
    div []
        [ h1 [ class "title" ] [ text "Sokoban" ]
        , div [ class "level-status" ]
            [ span [ class "level" ] [ text str ]
            , span [] [ text " - " ]
            , a [ href "#", class "start-over", onClick RequestStartOverConfirmation ] [ text "Start over" ]
            ]
        ]



-- Popups


type alias LevelStats =
    { levelNumber : Int
    , moves : Int
    , pushes : Int
    }


endOfLevel : Bool -> String -> Html ()
endOfLevel visible str =
    div
        [ classList
            [ ( "popup", True )
            , ( "visible", visible )
            ]
        ]
        [ p
            [ class "preserve-line-breaks" ]
            [ text str ]
        , button
            [ class "keyboard-button dismiss-popup", onClick () ]
            [ text "OK" ]
        ]


confirm : Bool -> String -> Html Bool
confirm visible question =
    div
        [ classList
            [ ( "popup", True )
            , ( "visible", visible )
            ]
        ]
        [ p [ class "preserve-line-breaks" ] [ text question ]
        , button
            [ class "keyboard-button cancel", onClick False ]
            [ text "Cancel" ]
        , button
            [ class "keyboard-button confirm", onClick True ]
            [ text "OK" ]
        ]



-- GameInfo


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



-- Game


renderApp : Game -> Maybe String -> Bool -> Html Msg
renderApp game message isStartingOver =
    let
        level =
            Game.currentLevel game
    in
        case level of
            Just lvl ->
                div []
                    [ renderHeader ("Level " ++ toString (Level.number lvl))
                    , div [ style [ ( "position", "relative" ) ] ]
                        [ Html.map
                            (\b ->
                                if b then
                                    ConfirmStartOver
                                else
                                    CancelStartOver
                            )
                            (confirm isStartingOver "Are you sure you want to start over? All progress will be lost.")
                        , Html.map (\_ -> AdvanceLevel) (endOfLevel (Game.levelWon game) ("You completed level " ++ (Level.number lvl |> toString) ++ "\nwith " ++ (Level.moves lvl |> toString) ++ " moves \nand " ++ (Level.pushes lvl |> toString) ++ " pushes"))
                        , renderLevel lvl
                        , renderGameInfo { moves = Level.moves lvl, pushes = Level.pushes lvl, message = message }
                        , undoButtons { undoMove = UndoMove, undoLevel = UndoLevel }
                        , arrowKeys { up = Move Up, right = Move Right, down = Move Down, left = Move Left }
                        ]
                    ]

            Nothing ->
                div []
                    [ renderHeader "Game Over"
                    , div [ style [ ( "position", "relative" ) ] ]
                        [ Html.map
                            (\b ->
                                if b then
                                    ConfirmStartOver
                                else
                                    CancelStartOver
                            )
                            (confirm isStartingOver "Are you sure you want to start over? All progress will be lost.")
                        , renderLevel (Level.fromTemplate gameOver)
                        , renderGameOverInfo { moves = game.totalMoves, pushes = game.totalPushes, message = Just "Well done!" }
                        ]
                    ]
