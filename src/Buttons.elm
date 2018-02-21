port module UndoButtons exposing (..)

import List
import Set exposing (Set, insert, remove)
import Html exposing (..)
import Html.Attributes exposing (class, classList, style)
import Html.Events exposing (onMouseDown, onMouseUp)
import Keyboard exposing (..)
import Game exposing (GameObject(Block, Space), MovingObject(Player, Crate), emptyGame)
import Matrix


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
    , game : Game.Game
    , moves : Int
    , pushes : Int
    }


model : Model
model =
    { keysDown = Set.empty
    , game = Game.emptyGame ()
    , moves = 0
    , pushes = 0
    }


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


keyCodeToDirection : Int -> Game.Direction
keyCodeToDirection keyCode =
    if keyCode == keyCodes.left then
        Game.Left
    else if keyCode == keyCodes.up then
        Game.Up
    else if keyCode == keyCodes.right then
        Game.Right
    else if keyCode == keyCodes.down then
        Game.Down
    else
        Game.Down


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyDown keyCode ->
            if isKeyCodeRelevant keyCode then
                ( { model
                    | keysDown = insert keyCode model.keysDown
                    , game =
                        case Game.move (keyCodeToDirection keyCode) model.game of
                            Result.Ok ( game, _ ) ->
                                game

                            _ ->
                                model.game
                  }
                , undo (keyCodeToJSMsg msg)
                )
            else
                ( model, Cmd.none )

        KeyUp keyCode ->
            if isKeyCodeRelevant keyCode then
                ( { model
                    | keysDown = remove keyCode model.keysDown
                  }
                , Cmd.none
                )
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


printGameObject : GameObject -> Html Msg
printGameObject obj =
    let
        renderOccupant : GameObject -> List (Html Msg)
        renderOccupant obj =
            case obj of
                Game.Block ->
                    []

                Game.Space s ->
                    case s.occupant of
                        Nothing ->
                            []

                        Just Game.Player ->
                            [ div
                                [ style
                                    [ ( "width", "14px" )
                                    , ( "height", "14px" )
                                    , ( "background-color", "red" )
                                    ]
                                ]
                                []
                            ]

                        Just Game.Crate ->
                            [ div
                                [ style
                                    [ ( "width", "14px" )
                                    , ( "height", "14px" )
                                    , ( "background-color", "yellow" )
                                    ]
                                ]
                                []
                            ]
    in
        case obj of
            Game.Space s ->
                case s.kind of
                    Game.GoalField ->
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

                    Game.Path ->
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

            Game.Block ->
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



-- Game.Crate ->
--     div
--         [ style
--             [ ( "background-image", "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAwklEQVRYR+2W2w2AIAwAYThmUSdSZ2E4jMQmyFtsLTH4SaS9XqBFCuZPMucXNQCGCNLm7hrAVr4KhSJgEdqPUzTABkCSWO2bNaCnGUwkDbABkJx2qBzKzhnoA8AgYcjrgj820C8AtKxKQ/gG2ABSzbpgAs8AG0DNmDovd8LEewPsALeOHRmI/z8Dw8AwgGzAfwfEwtuLFUxDpE7YDtD4JoZO6GyPluIuxg18DdCYL7ct29QDA5wABLnLIWtnXjlS4x8HfjeSIYxtab0AAAAASUVORK5CYIIA')" )
--             , ( "background-repeat", "no-repeat" )
--             , ( "background-size", "20px 20px" )
--             , ( "background-color", "black" )
--             , ( "width", "20px" )
--             , ( "height", "20px" )
--             , ( "float", "left" )
--             ]
--         ]
--         []
-- Game.Player ->
--     div
--         [ style
--             [ ( "background-image", "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA70lEQVRYR+2XURKAIAhE9f6HtqnJmUJWWCPto/4ygscGmDmNXwW8mhmXlLFw/A5AKelwnHNCcMdzGV0xvi0hv817XwZQM5ffGykRocBcgKaS2XIFJSprC9bAMoBL4JvkkrQmiNarH6s7esIuA+j2eRGp1wzkurc7NAWWAbjajJnzmq3M+Hq/DGBKYFQTuwI/wHIF6ufx7vNUI1j/DWYXsHuQpGMAukpQaSvGaE9wT8KZAKFKhO2Gowo8AXikhBW487/Q5Do0JyIBKCW8gRkFPgPATkzXDHMZaWdCa8LtpztP57iMgKN3Dqce6tMmBGAD3QtmGY9VnUMAAAAASUVORK5CYIIA')" )
--             , ( "background-repeat", "no-repeat" )
--             , ( "background-size", "20px 20px" )
--             , ( "width", "20px" )
--             , ( "height", "20px" )
--             , ( "float", "left" )
--             ]
--         ]
--         []


printGrid : Matrix.Matrix Game.GameObject -> Html Msg
printGrid grid =
    let
        printRow : List GameObject -> Html Msg
        printRow objects =
            div [ style [ ( "overflow", "hidden" ) ] ] (List.map printGameObject objects)
    in
        div [ class "grid" ] (List.map printRow (Matrix.toList grid))


view : Model -> Html Msg
view model =
    div []
        [ printGrid model.game.grid
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
