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
        , Move(Move, Push)
        , Game
        , Direction(Left, Up, Right, Down)
        )
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
                                    (case moveType of
                                        Push ->
                                            model.pushes + 1

                                        _ ->
                                            model.pushes
                                    )
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


printGameObject : GameElement -> Html Msg
printGameObject obj =
    let
        renderOccupant : GameElement -> List (Html Msg)
        renderOccupant obj =
            case obj of
                Block ->
                    []

                Space s ->
                    case s.occupant of
                        Nothing ->
                            []

                        Just Player ->
                            [ div
                                [ style
                                    [ ( "background-image", "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA70lEQVRYR+2XURKAIAhE9f6HtqnJmUJWWCPto/4ygscGmDmNXwW8mhmXlLFw/A5AKelwnHNCcMdzGV0xvi0hv817XwZQM5ffGykRocBcgKaS2XIFJSprC9bAMoBL4JvkkrQmiNarH6s7esIuA+j2eRGp1wzkurc7NAWWAbjajJnzmq3M+Hq/DGBKYFQTuwI/wHIF6ufx7vNUI1j/DWYXsHuQpGMAukpQaSvGaE9wT8KZAKFKhO2Gowo8AXikhBW487/Q5Do0JyIBKCW8gRkFPgPATkzXDHMZaWdCa8LtpztP57iMgKN3Dqce6tMmBGAD3QtmGY9VnUMAAAAASUVORK5CYIIA')" )
                                    , ( "background-repeat", "no-repeat" )
                                    , ( "background-size", "20px 20px" )
                                    , ( "width", "20px" )
                                    , ( "height", "20px" )
                                    , ( "float", "left" )
                                    ]
                                ]
                                []
                            ]

                        Just Crate ->
                            [ div
                                [ style
                                    [ ( "background-image", "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAwklEQVRYR+2W2w2AIAwAYThmUSdSZ2E4jMQmyFtsLTH4SaS9XqBFCuZPMucXNQCGCNLm7hrAVr4KhSJgEdqPUzTABkCSWO2bNaCnGUwkDbABkJx2qBzKzhnoA8AgYcjrgj820C8AtKxKQ/gG2ABSzbpgAs8AG0DNmDovd8LEewPsALeOHRmI/z8Dw8AwgGzAfwfEwtuLFUxDpE7YDtD4JoZO6GyPluIuxg18DdCYL7ct29QDA5wABLnLIWtnXjlS4x8HfjeSIYxtab0AAAAASUVORK5CYIIA')" )
                                    , ( "background-repeat", "no-repeat" )
                                    , ( "background-size", "20px 20px" )
                                    , ( "width", "20px" )
                                    , ( "height", "20px" )
                                    , ( "float", "left" )
                                    ]
                                ]
                                []
                            ]
    in
        case obj of
            Space s ->
                case s.kind of
                    GoalField ->
                        div
                            [ style
                                [ ( "background-size", "20px 20px" )
                                , ( "background-color", "black" )
                                , ( "width", "20px" )
                                , ( "height", "20px" )
                                , ( "float", "left" )
                                ]
                            ]
                            (renderOccupant obj)

                    Path ->
                        div
                            [ style
                                [ ( "background-size", "20px 20px" )
                                , ( "background-color", "cyan" )
                                , ( "width", "20px" )
                                , ( "height", "20px" )
                                , ( "float", "left" )
                                ]
                            ]
                            (renderOccupant obj)

            Block ->
                div
                    [ style
                        [ ( "background-image", "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAaklEQVRYR+3XOQ7AIAxE0XD/4yQVS8HJjIRkCqdIBVPkUyMYP7mZZGZ2Cc5T2/w1/S6AT95z1wh8BvALu9bCJ/f3XztAAAQQQAABBBBAAAEEEJAJxMKwqxfEd1cvkAW4S53tODaWYwLqAAMAoAJYuhkgzQAAAABJRU5ErkJgggAA')" )
                        , ( "background-repeat", "no-repeat" )
                        , ( "background-size", "20px 20px" )
                        , ( "width", "20px" )
                        , ( "height", "20px" )
                        , ( "float", "left" )
                        ]
                    ]
                    []


printGrid : Matrix.Matrix GameElement -> Html Msg
printGrid grid =
    let
        printRow : List GameElement -> Html Msg
        printRow objects =
            div [ style [ ( "overflow", "hidden" ) ] ] (List.map printGameObject objects)
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
