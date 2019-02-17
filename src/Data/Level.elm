module Data.Level exposing
    ( Grid
    , Level
    , fromTemplate
    , getGrid
    , hasWon
    , move
    , moves
    , number
    , pushes
    , reset
    , undo
    , view
    )

import Array exposing (Array)
import Data.GameElement as GameElement exposing (GameElement(..), MovingObject(..))
import Data.LevelTemplate exposing (LevelTemplate)
import Data.Movement exposing (Direction(..), MoveError(..))
import Html exposing (Html)
import Html.Attributes as Attrs


type alias Grid =
    Array GameElement


type alias Location =
    Int



-- LEVEL


type alias LevelState =
    { grid : Grid
    , playerLocation : Location
    , moves : Int
    , pushes : Int
    }


type alias Level =
    { number : Int
    , initial : LevelState
    , previous : Maybe LevelState
    , current : LevelState
    }


{-| The only way to instantiate a new game. Should contain validation of
the passed level to make sure that it's "correct"
-}
fromTemplate : LevelTemplate -> Level
fromTemplate tmpl =
    let
        fromStrings : List String -> Grid
        fromStrings strs =
            strs
                |> List.map (String.split "")
                |> List.concat
                |> Array.fromList
                |> Array.map GameElement.fromString

        levelState =
            { grid = fromStrings tmpl.grid, playerLocation = tmpl.playerLocation, moves = 0, pushes = 0 }
    in
    { current = levelState, initial = levelState, previous = Nothing, number = tmpl.levelNumber }


hasWon : Level -> Bool
hasWon { current } =
    current.grid
        |> Array.toList
        |> List.filter GameElement.isGoalField
        |> List.all GameElement.hasCrate


getGrid : Level -> Grid
getGrid { current } =
    current.grid


move : Direction -> Level -> Result MoveError Level
move direction level =
    let
        currentLevelState =
            level.current

        grid =
            currentLevelState.grid

        oneSpaceAway =
            getAdjacentLocation currentLevelState.playerLocation direction

        twoSpacesAway =
            getAdjacentLocation oneSpaceAway direction
    in
    case
        ( elementAt currentLevelState.playerLocation grid
        , elementAt oneSpaceAway grid
        , elementAt twoSpacesAway grid
        )
    of
        -- There is a block in the way
        ( _, Block, _ ) ->
            Result.Err BlockedByBlock

        -- There is a crate followed by a block
        ( _, OccupiedSpace _ Crate, Block ) ->
            Result.Err BlockedByCrate

        -- There are two adjacent crates
        ( _, OccupiedSpace _ Crate, OccupiedSpace _ Crate ) ->
            Result.Err BlockedByCrate

        -- There is a free space adjacent to the player
        ( OccupiedSpace playerSpaceType _, FreeSpace adjacantSpaceType, _ ) ->
            let
                newGrid =
                    grid
                        |> Array.set currentLevelState.playerLocation (FreeSpace playerSpaceType)
                        |> Array.set oneSpaceAway (OccupiedSpace adjacantSpaceType Player)

                newLevelState =
                    { currentLevelState
                        | grid = newGrid
                        , playerLocation = oneSpaceAway
                        , moves = currentLevelState.moves + 1
                    }
            in
            Result.Ok
                { level
                    | current = newLevelState
                    , previous = Just currentLevelState
                }

        -- There adjacent space is occupied by a crate, and adjacent to that there is a free space
        ( OccupiedSpace playerSpaceType _, OccupiedSpace adjacentSpaceType Crate, FreeSpace farAwaySpaceType ) ->
            let
                newGrid =
                    grid
                        |> Array.set currentLevelState.playerLocation (FreeSpace playerSpaceType)
                        |> Array.set oneSpaceAway (OccupiedSpace adjacentSpaceType Player)
                        |> Array.set twoSpacesAway (OccupiedSpace farAwaySpaceType Crate)

                newLevelState =
                    { currentLevelState
                        | grid = newGrid
                        , playerLocation = oneSpaceAway
                        , moves = currentLevelState.moves + 1
                        , pushes = currentLevelState.pushes + 1
                    }
            in
            Result.Ok
                { level
                    | current = newLevelState
                    , previous = Just currentLevelState
                }

        _ ->
            Result.Err Impossible


undo : Level -> Level
undo lvl =
    case lvl.previous of
        Just lvlState ->
            { lvl | current = lvlState, previous = Nothing }

        Nothing ->
            lvl


reset : Level -> Level
reset lvl =
    { lvl | current = lvl.initial, previous = Nothing }


moves : Level -> Int
moves lvl =
    lvl.current.moves


pushes : Level -> Int
pushes lvl =
    lvl.current.pushes


number : Level -> Int
number lvl =
    lvl.number


view : Level -> Html msg
view level =
    Html.div
        [ Attrs.class "grid" ]
        (level.current.grid
            |> Array.toList
            |> List.map GameElement.view
        )



-- HELPERS


getAdjacentLocation : Location -> Direction -> Location
getAdjacentLocation location direction =
    case direction of
        Left ->
            location - 1

        Up ->
            location - 19

        Right ->
            location + 1

        Down ->
            location + 19


elementAt : Location -> Grid -> GameElement
elementAt location grid =
    Array.get location grid |> Maybe.withDefault Block
