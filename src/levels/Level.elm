module Level exposing (..)

import Game exposing (Game, Grid, GameObject(..), MovingObject(..), SpaceType(..))
import Matrix exposing (Matrix, Location)


type alias Level =
    { grid : List String, playerLocation : Location }


level0 : Level
level0 =
    { grid =
        [ "###################"
        , "###################"
        , "###################"
        , "###################"
        , "###################"
        , "###################"
        , "##########...######"
        , "##########.#c######"
        , "##########...x#####"
        , "######p.c....x#####"
        , "###################"
        , "###################"
        , "###################"
        , "###################"
        , "###################"
        , "###################"
        , "###################"
        ]
    , playerLocation = ( 9, 6 )
    }


toGame : Level -> Game
toGame lvl =
    { lvl | grid = (fromStrings lvl.grid) }


fromStrings : List String -> Grid
fromStrings strs =
    strs
        |> List.map (String.split "")
        |> Matrix.fromList
        |> Matrix.map stringToGameObject


stringToGameObject : String -> GameObject
stringToGameObject str =
    case str of
        "#" ->
            Block

        "." ->
            Space { kind = Path, occupant = Nothing }

        "c" ->
            Space { kind = Path, occupant = Just Crate }

        "x" ->
            Space { kind = GoalField, occupant = Nothing }

        "p" ->
            Space { kind = Path, occupant = Just Player }

        _ ->
            Block
