port module Main exposing (..)

import List
import Set exposing (Set, insert, remove)
import Html exposing (..)
import Html.Attributes exposing (class, classList, style, attribute, href)
import Html.Events exposing (onMouseDown, onMouseUp, onClick)
import Keyboard exposing (..)
import Data.GameElement
    exposing
        ( GameElement(Block, Space)
        , MovingObject(Player, Crate)
        , SpaceType(Path, GoalField)
        )
import Data.Level as Level exposing (Level)
import Views.GameElement exposing (renderGameElement)
import Matrix
import Data.LevelTemplate exposing (level0, level1)
import Data.Movement as Movement exposing (Direction(..), MoveError(..))
import Data.Game as Game exposing (Game(..))


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { keysDown : Set Int
    , game : Game
    , message : Maybe String
    }


initialModel : Model
initialModel =
    let
        game =
            Game.initialise level0 [ level1 ]

        levelNumber =
            game |> Game.currentLevel |> Level.number
    in
        { keysDown = Set.empty
        , game = game
        , message = Just ("Playing level " ++ toString levelNumber ++ "...")
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- UPDATE


type Msg
    = Move Direction
    | UndoMove
    | UndoLevel
    | StartOver
    | KeyDown KeyCode
    | KeyUp KeyCode
    | AdvanceLevel
    | NoOp


port undo : String -> Cmd msg


getErrorMessage : MoveError -> String
getErrorMessage err =
    case err of
        Impossible ->
            "This should not happen..."

        OutOfBounds ->
            "How did you get here???"

        BlockedByCrate ->
            "{ooph...grumble}"

        BlockedByBlock ->
            "Ouch!"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Move direction ->
            case Game.move direction model.game of
                Result.Ok game ->
                    let
                        newModel =
                            { model
                                | game = game
                                , message = Nothing
                            }
                    in
                        ( newModel, Cmd.none )

                Result.Err err ->
                    ( { model | message = Just (getErrorMessage err) }
                    , Cmd.none
                    )

        UndoMove ->
            ( { model | game = Game.undoMove model.game, message = Just "Whew! That was close!" }, Cmd.none )

        UndoLevel ->
            ( { model | game = Game.undoLevel model.game, message = Just "Not so easy, is it?" }, Cmd.none )

        AdvanceLevel ->
            let
                newGame =
                    Game.advanceLevel model.game

                newMessage =
                    "Playing level " ++ (newGame |> Game.currentLevel |> Level.number |> toString) ++ "..."
            in
                ( { model | game = newGame, message = Just newMessage }, Cmd.none )

        StartOver ->
            ( initialModel, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- VIEW


keyboardButton : List String -> Msg -> String -> Html Msg
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


printGrid : Matrix.Matrix GameElement -> Html Msg
printGrid grid =
    let
        printRow : List GameElement -> Html Msg
        printRow objects =
            div [ style [ ( "overflow", "hidden" ) ] ] (List.map renderGameElement objects)
    in
        div [ style [ ( "margin", "0 auto" ), ( "width", "304px" ) ] ] (List.map printRow (Matrix.toList grid))


view : Model -> Html Msg
view { game, message } =
    let
        level =
            Game.currentLevel game
    in
        div []
            [ h1 [ class "title" ] [ text "Sokoban" ]
            , div [ class "level-status" ]
                [ span [ class "level" ] [ text ("Level " ++ toString (Level.number level)) ]
                , span [] [ text " - " ]
                , a [ href "#", class "start-over", onClick StartOver ] [ text "Start over" ]
                ]
            , div [ style [ ( "position", "relative" ) ] ]
                [ div
                    [ classList
                        [ ( "popup", True )
                        , ( "visible", Game.levelWon game )
                        ]
                    ]
                    [ p
                        []
                        [ text ("You completed level " ++ (Level.number level |> toString))
                        , br [] []
                        , text ("with " ++ (Level.moves level |> toString) ++ " moves")
                        , br [] []
                        , text ("and " ++ (Level.pushes level |> toString) ++ " pushes")
                        ]
                    , button
                        [ class "keyboard-button dismiss-popup" ]
                        [ text "OK" ]
                    , button
                        [ class "keyboard-button dismiss-popup", onClick AdvanceLevel ]
                        [ text "OK" ]
                    ]
                , printGrid (Level.grid level)
                , div [ class "game-info" ]
                    [ div [ class "movement-info" ]
                        [ div [ class "moves" ]
                            [ ((Level.moves level |> toString) ++ " moves") |> text ]
                        , div [ class "pushes" ]
                            [ ((Level.pushes level |> toString) ++ " pushes") |> text ]
                        ]
                    , div [ class "game-feedback" ]
                        [ Maybe.withDefault "" message |> text ]
                    ]
                , div [ class "undo-buttons" ]
                    [ keyboardButton [ "undo-move" ] UndoMove "Undo Move (M)"
                    , keyboardButton [ "undo-level" ] UndoLevel "Undo Level (L)"
                    ]
                , div [ class "arrow-buttons" ]
                    [ div [ class "top-row" ]
                        [ keyboardButton [ "arrow-button", "up-arrow" ] (Move Up) "▲" ]
                    , div [ class "bottom-row" ]
                        [ keyboardButton [ "arrow-button", "up-arrow" ] (Move Left) "◀"
                        , keyboardButton [ "arrow-button", "down-arrow" ] (Move Down) "▼"
                        , keyboardButton [ "arrow-button", "right-arrow" ] (Move Right) "▶"
                        ]
                    ]
                ]
            ]



-- SUBSCRIPTIONS


keyCodeToMsg : KeyCode -> Msg
keyCodeToMsg keyCode =
    case keyCode of
        37 ->
            Move Left

        38 ->
            Move Up

        39 ->
            Move Right

        40 ->
            Move Down

        76 ->
            UndoLevel

        77 ->
            UndoMove

        _ ->
            NoOp


keyUpToMsg : KeyCode -> Msg
keyUpToMsg keyCode =
    NoOp


subscriptions : Model -> Sub Msg
subscriptions { game } =
    case game of
        Playing _ ->
            Sub.batch
                [ Keyboard.downs keyCodeToMsg
                , Keyboard.ups keyUpToMsg
                ]

        LevelWon _ ->
            Keyboard.downs
                (\keyCode ->
                    if keyCode == 13 then
                        AdvanceLevel
                    else
                        NoOp
                )

        _ ->
            Sub.none
