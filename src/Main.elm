port module Main exposing (..)

import List
import Set exposing (Set, insert, remove)
import Html exposing (..)
import Html.Attributes exposing (class, classList, style, attribute)
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
import Data.LevelTemplate exposing (level0)
import Data.Movement as Movement exposing (Direction(..), MoveError(..))


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
    , level : Level
    , message : Maybe String
    }


model : Model
model =
    { keysDown = Set.empty
    , level = Level.fromTemplate level0
    , message = Just "Playing level 0..."
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )



-- UPDATE


type Msg
    = Move Direction
    | UndoMove
    | UndoLevel
    | KeyDown KeyCode
    | KeyUp KeyCode
    | LoadLevel Int
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
            case Level.move direction model.level of
                Result.Ok level ->
                    let
                        newModel =
                            { model
                                | level = level
                                , message = Nothing
                            }
                    in
                        ( newModel, Cmd.none )

                Result.Err err ->
                    ( { model | message = Just (getErrorMessage err) }
                    , Cmd.none
                    )

        UndoMove ->
            ( { model | level = Level.undo model.level }, Cmd.none )

        UndoLevel ->
            ( { model | level = Level.reset model.level }, Cmd.none )

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
view { level, message } =
    div [ style [ ( "position", "relative" ) ] ]
        [ div
            [ class "popup"
            , attribute "popup" ""
            ]
            [ p
                [ attribute "popup-text" "" ]
                [ text "You completed level 0"
                , br [] []
                , text "with 21 moves"
                , br [] []
                , text "and 7 pushes"
                ]
            , button
                [ attribute "dismiss-popup" ""
                , class "keyboard-button dismiss-popup"
                ]
                [ text "OK" ]
            ]
        , printGrid (Level.grid level)
        , div [ style [ ( "margin", "0 auto" ), ( "width", "304px" ) ] ]
            [ div []
                [ (toString (Level.moves level)) ++ " moves" |> text ]
            , div []
                [ (toString (Level.pushes level)) ++ " pushes" |> text ]
            , div []
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
subscriptions { level } =
    if Level.hasWon level then
        Sub.none
    else
        Sub.batch
            [ Keyboard.downs keyCodeToMsg
            , Keyboard.ups keyUpToMsg
            ]
