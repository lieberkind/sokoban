module Data.GameElement exposing (GameElement(..), MovingObject(..), SpaceType(..), deoccupy, fromString, hasCrate, isGoalField, occupyWith)


type SpaceType
    = GoalField
    | Path


type MovingObject
    = Player
    | Crate


{-| A GameElement can either be a Block or a Space.

A space can potentially hold a MovingObject.

Todo: it feels wrong to have the "kind" property here... How can I fix that?

-}
type GameElement
    = Block
    | OccupiedSpace SpaceType MovingObject
    | FreeSpace SpaceType


fromString : String -> GameElement
fromString str =
    case str of
        "#" ->
            Block

        "." ->
            FreeSpace Path

        "c" ->
            OccupiedSpace Path Crate

        "x" ->
            FreeSpace GoalField

        "w" ->
            OccupiedSpace GoalField Crate

        "q" ->
            OccupiedSpace GoalField Player

        "p" ->
            OccupiedSpace Path Player

        _ ->
            Block


isGoalField : GameElement -> Bool
isGoalField gameElement =
    case gameElement of
        FreeSpace GoalField ->
            True

        OccupiedSpace GoalField _ ->
            True

        _ ->
            False


hasCrate : GameElement -> Bool
hasCrate gameElement =
    case gameElement of
        OccupiedSpace _ Crate ->
            True

        _ ->
            False


occupyWith : MovingObject -> GameElement -> GameElement
occupyWith movingObject gameElement =
    case gameElement of
        FreeSpace spaceType ->
            OccupiedSpace spaceType movingObject

        _ ->
            gameElement


deoccupy : GameElement -> GameElement
deoccupy gameElement =
    case gameElement of
        OccupiedSpace spaceType _ ->
            FreeSpace spaceType

        _ ->
            gameElement
