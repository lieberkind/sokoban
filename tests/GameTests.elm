module GameTests exposing (suite)

import Data.Game as Game exposing (Game)
import Data.GameElement as GameElement exposing (GameElement(..), MovingObject(..), SpaceType(..))
import Data.Level as Level
import Data.Movement exposing (Direction(..))
import Expect
import Test exposing (Test, describe, test)



-- HELPERS


{-| A solution to level 0: 21 moves, 7 pushes.
-}
level0Solution : List Direction
level0Solution =
    List.repeat 6 Right
        ++ [ Left, Left, Up, Up, Up, Right, Right, Down ]
        ++ [ Up, Left, Left, Down, Down, Right, Right ]


play : List Direction -> Game -> Game
play directions game =
    List.foldl
        (\dir g -> Game.move dir g |> Result.withDefault g)
        game
        directions


currentLevelNumber : Game -> Maybe Int
currentLevelNumber =
    Game.currentLevel >> Maybe.map Level.number



-- TESTS


suite : Test
suite =
    describe "Data.Game"
        [ test "a new game starts on level 0" <|
            \_ ->
                Game.new
                    |> currentLevelNumber
                    |> Expect.equal (Just 0)
        , test "solving a level marks it as won" <|
            \_ ->
                Game.new
                    |> play level0Solution
                    |> Expect.all
                        [ Game.levelWon >> Expect.equal True
                        , Game.isPlaying >> Expect.equal False
                        ]
        , test "advancing after a win moves to the next level and adds up the totals" <|
            \_ ->
                Game.new
                    |> play level0Solution
                    |> Game.advanceLevel
                    |> Expect.all
                        [ currentLevelNumber >> Expect.equal (Just 1)
                        , Game.isPlaying >> Expect.equal True
                        , Game.getTotalMoves >> Expect.equal 21
                        , Game.getTotalPushes >> Expect.equal 7
                        , Game.toProgress
                            >> Expect.equal (Just { levelNumber = 1, totalMoves = 21, totalPushes = 7 })
                        ]
        , test "advancing is ignored while the level isn't won" <|
            \_ ->
                Game.new
                    |> Game.advanceLevel
                    |> currentLevelNumber
                    |> Expect.equal (Just 0)
        , test "moves are ignored once the level is won" <|
            \_ ->
                let
                    won =
                        Game.new |> play level0Solution
                in
                Game.move Left won
                    |> Expect.equal (Ok won)
        , test "undoing the level resets the current level" <|
            \_ ->
                Game.new
                    |> play [ Right, Right ]
                    |> Game.undoLevel
                    |> Game.currentLevel
                    |> Maybe.map (\l -> ( Level.moves l, Level.pushes l ))
                    |> Expect.equal (Just ( 0, 0 ))
        , describe "fromProgress"
            [ test "resumes at the saved level with the saved totals" <|
                \_ ->
                    Game.fromProgress { levelNumber = 5, totalMoves = 300, totalPushes = 80 }
                        |> Expect.all
                            [ currentLevelNumber >> Expect.equal (Just 5)
                            , Game.getTotalMoves >> Expect.equal 300
                            , Game.getTotalPushes >> Expect.equal 80
                            ]
            , test "falls back to the first level when the saved level doesn't exist" <|
                \_ ->
                    Game.fromProgress { levelNumber = 999, totalMoves = 0, totalPushes = 0 }
                        |> currentLevelNumber
                        |> Expect.equal (Just 0)
            ]
        , describe "GameElement.fromString"
            [ test "parses every level character" <|
                \_ ->
                    [ "#", ".", "c", "x", "w", "q", "p" ]
                        |> List.map GameElement.fromString
                        |> Expect.equal
                            [ Block
                            , FreeSpace Path
                            , OccupiedSpace Path Crate
                            , FreeSpace GoalField
                            , OccupiedSpace GoalField Crate
                            , OccupiedSpace GoalField Player
                            , OccupiedSpace Path Player
                            ]
            ]
        ]
