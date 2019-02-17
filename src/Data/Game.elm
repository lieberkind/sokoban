module Data.Game exposing
    ( Game
    , Model
    , Msg
    , advanceLevel
    , currentLevel
    , fromProgress
    , getTotalMoves
    , getTotalPushes
    , isGameOver
    , isPlaying
    , levelWon
    , move
    , new
    , subscriptions
    , toProgress
    , undoLevel
    , undoMove
    , update
    , view
    )

import Browser.Events as BrowserEvents
import Data.Level as Level exposing (..)
import Data.LevelTemplate as LevelTemplate exposing (LevelTemplate)
import Data.Movement as Movement exposing (Direction, MoveError(..))
import Data.Progress exposing (Progress)
import Html exposing (Html)
import Html.Attributes as Attrs
import Json.Decode as Decode
import List.Nonempty as NE exposing (Nonempty(..))



--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------


type alias Model =
    { game : Game
    , message : Message
    }


type Game
    = Game
        { state : GameState
        , levels : Nonempty Level
        , totalMoves : Int
        , totalPushes : Int
        }


type GameState
    = Playing
    | LevelWon
    | GameOver


type Message
    = Message String
    | NoMessage



--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------


new : Model
new =
    { message = Message "Playing level 0..."
    , game =
        Game
            { state = Playing
            , levels = NE.map Level.fromTemplate LevelTemplate.allLevels
            , totalMoves = 0
            , totalPushes = 0
            }
    }


fromProgress : Progress -> Model
fromProgress { levelNumber, totalMoves, totalPushes } =
    let
        levelsToPlay =
            LevelTemplate.allLevels
                |> NE.toList
                |> List.filter (\template -> template.levelNumber >= levelNumber)
                |> NE.fromList
                |> Maybe.withDefault LevelTemplate.allLevels
                |> NE.map Level.fromTemplate

        game =
            Game
                { state = Playing
                , levels = levelsToPlay
                , totalMoves = totalMoves
                , totalPushes = totalPushes
                }
    in
    { game = game, message = NoMessage }



--------------------------------------------------------------------------------
-- UPDATE
--------------------------------------------------------------------------------


type Msg
    = Move Direction
    | UndoMove
    | UndoLevel
    | NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        Move direction ->
            case move direction model.game of
                Result.Ok newGame ->
                    { model | game = newGame, message = NoMessage }

                Result.Err err ->
                    { model | message = Message (Movement.errorToString err) }

        UndoMove ->
            { model | game = undoMove model.game }

        UndoLevel ->
            { model | game = undoLevel model.game }

        NoOp ->
            model


move : Direction -> Game -> Result MoveError Game
move dir ((Game { state }) as game) =
    case state of
        Playing ->
            Level.move dir (safeCurrentLevel game) |> Result.map (updateGame game)

        _ ->
            Result.Ok game


undoMove : Game -> Game
undoMove ((Game { state }) as game) =
    case state of
        Playing ->
            updateGame game (Level.undo (safeCurrentLevel game))

        _ ->
            game


undoLevel : Game -> Game
undoLevel ((Game { state }) as game) =
    case state of
        GameOver ->
            game

        _ ->
            updateGame game (Level.reset (safeCurrentLevel game))


currentLevel : Model -> Maybe Level
currentLevel model =
    if isGameOver model then
        Nothing

    else
        Just (safeCurrentLevel model.game)


advanceLevel : Model -> Model
advanceLevel model =
    { model | game = advanceLevelInternal model.game }


advanceLevelInternal : Game -> Game
advanceLevelInternal ((Game { state, levels, totalMoves, totalPushes }) as game) =
    case state of
        LevelWon ->
            case NE.tail levels of
                [] ->
                    Game
                        { levels = levels
                        , state = GameOver
                        , totalMoves = totalMoves + Level.moves (safeCurrentLevel game)
                        , totalPushes = totalPushes + Level.pushes (safeCurrentLevel game)
                        }

                next :: rest ->
                    Game
                        { state = Playing
                        , levels = Nonempty next rest
                        , totalMoves = totalMoves + Level.moves (safeCurrentLevel game)
                        , totalPushes = totalPushes + Level.pushes (safeCurrentLevel game)
                        }

        _ ->
            game


levelWon : Model -> Bool
levelWon model =
    let
        game =
            case model.game of
                Game gameState ->
                    gameState
    in
    case game.state of
        LevelWon ->
            True

        _ ->
            False


isPlaying : Game -> Bool
isPlaying (Game game) =
    if game.state == Playing then
        True

    else
        False


isGameOver : Model -> Bool
isGameOver model =
    let
        game =
            case model.game of
                Game gameState ->
                    gameState
    in
    if game.state == GameOver then
        True

    else
        False


toProgress : Model -> Maybe Progress
toProgress model =
    toProgressInternal model.game


toProgressInternal : Game -> Maybe Progress
toProgressInternal ((Game { state, totalMoves, totalPushes }) as game) =
    case state of
        GameOver ->
            Nothing

        _ ->
            Just
                { levelNumber = Level.number (safeCurrentLevel game)
                , totalMoves = totalMoves
                , totalPushes = totalPushes
                }


getTotalMoves : Game -> Int
getTotalMoves (Game { totalMoves }) =
    totalMoves


getTotalPushes : Game -> Int
getTotalPushes (Game { totalPushes }) =
    totalPushes



--------------------------------------------------------------------------------
-- VIEW
--------------------------------------------------------------------------------


view : Model -> Html Msg
view model =
    let
        level =
            currentLevel model
    in
    case level of
        Just lvl ->
            Html.div []
                [ Level.view lvl
                , renderGameInfo
                    { moves = Level.moves lvl
                    , pushes = Level.pushes lvl
                    , message = model.message
                    }

                -- , Views.GameInfo.renderGameInfo { moves = Level.moves lvl, pushes = Level.pushes lvl, message = message }
                -- , Views.Controls.undoButtons { undoMove = UndoMove, undoLevel = UndoLevel }
                -- , Views.Controls.arrowKeys { up = Move Up, right = Move Right, down = Move Down, left = Move Left }
                -- ]
                ]

        Nothing ->
            Html.div []
                [ Level.view (Level.fromTemplate LevelTemplate.gameOver)

                -- , Views.GameInfo.renderGameOverInfo
                --     { moves = Game.getTotalMoves game
                --     , pushes = Game.getTotalPushes game
                --     , message = Just "Well done!"
                --     }
                ]


type alias GameInfo =
    { moves : Int
    , pushes : Int
    , message : Message
    }


gameInfo : String -> String -> String -> Html msg
gameInfo str1 str2 str3 =
    Html.div [ Attrs.class "game-info" ]
        [ Html.div [ Attrs.class "moves" ]
            [ Html.text str1 ]
        , Html.div [ Attrs.class "pushes" ]
            [ Html.text str2 ]
        , Html.div [ Attrs.class "feedback" ]
            [ Html.text str3 ]
        ]


renderGameInfo : GameInfo -> Html msg
renderGameInfo { moves, pushes, message } =
    gameInfo
        (String.fromInt moves ++ " moves")
        (String.fromInt pushes ++ " pushes")
        (case message of
            Message str ->
                str

            NoMessage ->
                ""
        )


renderGameOverInfo : GameInfo -> Html msg
renderGameOverInfo { moves, pushes, message } =
    gameInfo
        (String.fromInt moves ++ " total moves")
        (String.fromInt pushes ++ " total pushes")
        "Well done!"



--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------


updateGame : Game -> Level -> Game
updateGame (Game game) level =
    let
        newGameState =
            if Level.hasWon level then
                LevelWon

            else
                Playing

        newLevels =
            Nonempty level (NE.tail game.levels)
    in
    Game { game | levels = newLevels, state = newGameState }


safeCurrentLevel : Game -> Level
safeCurrentLevel (Game { levels }) =
    NE.head levels



--------------------------------------------------------------------------------
-- SUBSCRIPTIONS
--------------------------------------------------------------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    if isPlaying model.game then
        Sub.batch
            [ BrowserEvents.onKeyDown inGameKeyDecoder
            ]
        -- else if levelWon model.game then
        --BrowserEvents.onKeyDown endOfLevelKeyDecoder

    else
        Sub.none


inGameKeyDecoder : Decode.Decoder Msg
inGameKeyDecoder =
    Decode.map keyToMsg (Decode.field "key" Decode.string)



-- endOfLevelKeyDecoder : Decode.Decoder Msg
-- endOfLevelKeyDecoder =
--     Decode.map
--         (\key ->
--             case key of
--                 "Enter" ->
--                     AdvanceLevel
--
--                 _ ->
--                     NoOp
--         )
--         (Decode.field "key" Decode.string)


keyToMsg : String -> Msg
keyToMsg key =
    case key of
        "ArrowLeft" ->
            Move Movement.Left

        "ArrowRight" ->
            Move Movement.Right

        "ArrowUp" ->
            Move Movement.Up

        "ArrowDown" ->
            Move Movement.Down

        "L" ->
            UndoLevel

        "l" ->
            UndoLevel

        "M" ->
            UndoMove

        "m" ->
            UndoMove

        _ ->
            NoOp
