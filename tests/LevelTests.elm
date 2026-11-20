module LevelTests exposing (suite)

import Array
import Data.GameElement exposing (GameElement(..), MovingObject(..), SpaceType(..))
import Data.Level as Level exposing (Level)
import Data.Movement exposing (Direction(..), MoveError(..))
import Expect
import Test exposing (Test, describe, test)



-- HELPERS


{-| Levels are 19 columns wide (Level.move relies on this), so test levels
are built from short rows padded with blocks to that width.
-}
levelFrom : List String -> Level
levelFrom rows =
    let
        wall =
            String.repeat 19 "#"

        padded =
            List.map (\row -> String.padRight 19 '#' ("#" ++ row)) rows

        grid =
            wall :: padded ++ [ wall ]

        playerLocation =
            grid
                |> String.concat
                |> String.indexes "p"
                |> List.append (String.indexes "q" (String.concat grid))
                |> List.head
                |> Maybe.withDefault -1
    in
    Level.fromTemplate
        { levelNumber = 1, grid = grid, playerLocation = playerLocation }


at : Int -> Int -> Level -> Maybe GameElement
at row col level =
    -- Rows and columns are relative to the padded test area (inside the wall).
    Array.get ((row + 1) * 19 + col + 1) (Level.getGrid level)


moveAll : List Direction -> Level -> Result MoveError Level
moveAll directions level =
    List.foldl (\dir acc -> Result.andThen (Level.move dir) acc) (Ok level) directions



-- TESTS


suite : Test
suite =
    describe "Data.Level"
        [ describe "move"
            [ test "walking onto a free path moves the player and counts a move" <|
                \_ ->
                    levelFrom [ "p.." ]
                        |> Level.move Right
                        |> Result.map
                            (\l -> ( at 0 0 l, at 0 1 l, ( Level.moves l, Level.pushes l ) ))
                        |> Expect.equal
                            (Ok
                                ( Just (FreeSpace Path)
                                , Just (OccupiedSpace Path Player)
                                , ( 1, 0 )
                                )
                            )
            , test "moving vertically uses the full row width" <|
                \_ ->
                    levelFrom [ "p", "." ]
                        |> Level.move Down
                        |> Result.map (at 1 0)
                        |> Expect.equal (Ok (Just (OccupiedSpace Path Player)))
            , test "walking into a block is refused" <|
                \_ ->
                    levelFrom [ "p." ]
                        |> Level.move Left
                        |> Expect.equal (Err BlockedByBlock)
            , test "pushing a crate onto a free space moves both and counts a push" <|
                \_ ->
                    levelFrom [ "pc." ]
                        |> Level.move Right
                        |> Result.map
                            (\l -> ( at 0 1 l, at 0 2 l, ( Level.moves l, Level.pushes l ) ))
                        |> Expect.equal
                            (Ok
                                ( Just (OccupiedSpace Path Player)
                                , Just (OccupiedSpace Path Crate)
                                , ( 1, 1 )
                                )
                            )
            , test "pushing a crate into a block is refused" <|
                \_ ->
                    levelFrom [ "pc" ]
                        |> Level.move Right
                        |> Expect.equal (Err BlockedByCrate)
            , test "pushing two crates in a row is refused" <|
                \_ ->
                    levelFrom [ "pcc." ]
                        |> Level.move Right
                        |> Expect.equal (Err BlockedByCrate)
            , test "a goal field stays a goal field after the player leaves it" <|
                \_ ->
                    levelFrom [ "q." ]
                        |> Level.move Right
                        |> Result.map (at 0 0)
                        |> Expect.equal (Ok (Just (FreeSpace GoalField)))
            , test "a crate pushed off a goal field leaves the goal field behind" <|
                \_ ->
                    levelFrom [ "pw." ]
                        |> Level.move Right
                        |> Result.map (\l -> ( at 0 1 l, at 0 2 l ))
                        |> Expect.equal
                            (Ok
                                ( Just (OccupiedSpace GoalField Player)
                                , Just (OccupiedSpace Path Crate)
                                )
                            )
            , test "a crate can be pushed repeatedly until it hits a wall" <|
                \_ ->
                    levelFrom [ "p.c." ]
                        |> moveAll [ Right, Right, Right ]
                        |> Expect.equal (Err BlockedByCrate)
            ]
        , describe "hasWon"
            [ test "is false while a goal field has no crate" <|
                \_ ->
                    levelFrom [ "pcx" ]
                        |> Level.hasWon
                        |> Expect.equal False
            , test "is true once every goal field has a crate" <|
                \_ ->
                    levelFrom [ "pcx" ]
                        |> Level.move Right
                        |> Result.map Level.hasWon
                        |> Expect.equal (Ok True)
            ]
        , describe "undo and reset"
            [ test "undo restores the state before the last move" <|
                \_ ->
                    let
                        level =
                            levelFrom [ "p.c." ]
                    in
                    level
                        |> moveAll [ Right, Right ]
                        |> Result.map Level.undo
                        |> Result.map (\l -> ( at 0 1 l, at 0 2 l, ( Level.moves l, Level.pushes l ) ))
                        |> Expect.equal
                            (Ok
                                ( Just (OccupiedSpace Path Player)
                                , Just (OccupiedSpace Path Crate)
                                , ( 1, 0 )
                                )
                            )
            , test "undo without any moves does nothing" <|
                \_ ->
                    let
                        level =
                            levelFrom [ "p." ]
                    in
                    Level.undo level
                        |> Expect.equal level
            , test "reset restores the level to its initial state" <|
                \_ ->
                    let
                        level =
                            levelFrom [ "p.c.." ]
                    in
                    level
                        |> moveAll [ Right, Right, Right ]
                        |> Result.map (Level.reset >> .current)
                        |> Expect.equal (Ok level.current)
            ]
        ]
