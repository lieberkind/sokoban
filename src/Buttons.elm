port module UndoButtons exposing (..)

import List
import Set exposing (Set, insert, remove)
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onMouseDown, onMouseUp)
import Keyboard exposing (..)


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
    }


model : Model
model =
    { keysDown = Set.empty }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )



-- UPDATE


type Msg
    = KeyDown KeyCode
    | KeyUp KeyCode
    | NoOp


port undo : String -> Cmd msg


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyDown keyCode ->
            if isKeyCodeRelevant keyCode then
                ( { model | keysDown = insert keyCode model.keysDown }, undo (keyCodeToJSMsg msg) )
            else
                ( model, Cmd.none )

        KeyUp keyCode ->
            if isKeyCodeRelevant keyCode then
                ( { model | keysDown = remove keyCode model.keysDown }, Cmd.none )
            else
                ( model, Cmd.none )

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


view : Model -> Html Msg
view model =
    div []
        [ div [ class "undo-buttons" ]
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



-- SUBSCRIPTIONS


keyDownToMsg : KeyCode -> Msg
keyDownToMsg keyCode =
    if isKeyCodeRelevant keyCode then
        KeyDown keyCode
    else
        NoOp


keyUpToMsg : KeyCode -> Msg
keyUpToMsg keyCode =
    if isKeyCodeRelevant keyCode then
        KeyUp keyCode
    else
        NoOp


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs keyDownToMsg
        , Keyboard.ups keyUpToMsg
        ]
