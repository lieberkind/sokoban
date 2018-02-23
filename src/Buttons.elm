port module UndoButtons exposing (..)

import List
import Set exposing (Set, insert, remove)
import Html exposing (..)
import Html.Attributes exposing (class, classList, style)
import Html.Events exposing (onMouseDown, onMouseUp)
import Keyboard exposing (..)
import Data.GameElement
    exposing
        ( GameElement(Block, Space)
        , MovingObject(Player, Crate)
        , SpaceType(Path, GoalField)
        )
import Data.Game as Game
    exposing
        ( MoveError(..)
        , Movement(Move, Push)
        , Game
        , Direction(Left, Up, Right, Down)
        , isPush
        )
import Views.GameElement exposing (renderGameElement)
import Matrix
import Data.Level exposing (level0)


keyCodes : { down : Int, l : Int, left : Int, m : Int, up : Int, right : Int }
keyCodes =
    { left = 37
    , up = 38
    , right = 39
    , down = 40
    , l = 76
    , m = 77
    }


isKeyCodeRelevant : Int -> Bool
isKeyCodeRelevant keyCode =
    List.member keyCode [ keyCodes.left, keyCodes.up, keyCodes.right, keyCodes.down, keyCodes.l, keyCodes.m ]


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
    , moves : Int
    , pushes : Int
    , message : Maybe String
    }


model : Model
model =
    { keysDown = Set.empty
    , game = Game.fromLevel level0
    , moves = 0
    , pushes = 0
    , message = Just "Playing level 1..."
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


keyCodeToJSMsg : Msg -> String
keyCodeToJSMsg msg =
    case msg of
        KeyDown keyCode ->
            if keyCode == keyCodes.left then
                "MOVE_LEFT"
            else if keyCode == keyCodes.up then
                "MOVE_UP"
            else if keyCode == keyCodes.right then
                "MOVE_RIGHT"
            else if keyCode == keyCodes.down then
                "MOVE_DOWN"
            else if keyCode == keyCodes.l then
                "UNDO_LEVEL"
            else if keyCode == keyCodes.m then
                "UNDO_MOVE"
            else
                "NOOP"

        _ ->
            "NOOP"


keyCodeToDirection : Int -> Direction
keyCodeToDirection keyCode =
    if keyCode == keyCodes.left then
        Left
    else if keyCode == keyCodes.up then
        Up
    else if keyCode == keyCodes.right then
        Right
    else if keyCode == keyCodes.down then
        Down
    else
        Down


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Move direction ->
            case Game.move direction model.game of
                Result.Ok ( game, moveType ) ->
                    let
                        newModel =
                            { model
                                | game = game
                                , moves = model.moves + 1
                                , pushes =
                                    if Game.isPush moveType then
                                        model.pushes + 1
                                    else
                                        model.pushes
                                , message = Nothing
                            }
                    in
                        ( newModel, Cmd.none )

                Result.Err err ->
                    ( { model | message = Just (getErrorMessage err) }
                    , Cmd.none
                    )

        _ ->
            ( model, Cmd.none )



-- VIEW


keyboardButton : List String -> Int -> String -> Model -> Html Msg
keyboardButton classes keyCode label model =
    let
        defaultClasses =
            [ ( "keyboard-button", True )
            , ( "active", Set.member keyCode model.keysDown )
            ]

        customClasses =
            (List.map (\className -> ( className, True )) classes)
    in
        button
            [ classList (List.append defaultClasses customClasses)
            , onMouseDown (KeyDown keyCode)
            , onMouseUp (KeyUp keyCode)
            ]
            [ text label ]


printGrid : Matrix.Matrix GameElement -> Html Msg
printGrid grid =
    let
        printRow : List GameElement -> Html Msg
        printRow objects =
            div [ style [ ( "overflow", "hidden" ) ] ] (List.map renderGameElement objects)
    in
        div [ class "grid" ] (List.map printRow (Matrix.toList grid))


view : Model -> Html Msg
view model =
    div []
        [ printGrid (Game.grid model.game)
        , div []
            [ text
                (if Game.hasWon model.game then
                    "Game won"
                 else
                    "Game not won yet"
                )
            ]
        , div []
            [ (toString model.moves) ++ " moves" |> text ]
        , div []
            [ (toString model.pushes) ++ " pushes" |> text ]
        , div []
            [ Maybe.withDefault "" model.message |> text ]
        , div [ class "undo-buttons" ]
            [ keyboardButton [ "undo-move" ] keyCodes.m "Undo Move (M)" model
            , keyboardButton [ "undo-level" ] keyCodes.l "Undo Level (L)" model
            ]
        , div [ class "arrow-buttons" ]
            [ div [ class "top-row" ]
                [ keyboardButton [ "arrow-button", "up-arrow" ] keyCodes.up "▲" model ]
            , div [ class "bottom-row" ]
                [ keyboardButton [ "arrow-button", "up-arrow" ] keyCodes.left "◀" model
                , keyboardButton [ "arrow-button", "down-arrow" ] keyCodes.down "▼" model
                , keyboardButton [ "arrow-button", "right-arrow" ] keyCodes.right "▶" model
                ]
            ]
        ]


keyDownToMsg : KeyCode -> Msg
keyDownToMsg keyCode =
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
    if isKeyCodeRelevant keyCode then
        KeyUp keyCode
    else
        NoOp


subscriptions : Model -> Sub Msg
subscriptions model =
    if Game.hasWon model.game then
        Sub.none
    else
        Sub.batch
            [ Keyboard.downs keyDownToMsg
            , Keyboard.ups keyUpToMsg
            ]
