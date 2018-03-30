module Data.GameElement exposing (..)

import Data.Cyclic as Cyclic exposing (Cyclic)


type PlayerMood
    = Neutral
    | Content
    | Happy
    | Ecstatic


type SpaceType
    = GoalField
    | Path


type Occupant
    = None
    | Player (Cyclic PlayerMood)
    | Crate


type alias Occupyable =
    { kind : SpaceType, occupant : Occupant }


type GameElement
    = Block
    | Space Occupyable


fromString : String -> GameElement
fromString str =
    let
        moods =
            Cyclic.fromElements Neutral [ Content, Happy, Ecstatic, Happy, Content ]
    in
        case str of
            "#" ->
                Block

            "." ->
                Space { kind = Path, occupant = None }

            "c" ->
                Space { kind = Path, occupant = Crate }

            "p" ->
                Space { kind = Path, occupant = Player moods }

            "x" ->
                Space { kind = GoalField, occupant = None }

            "w" ->
                Space { kind = GoalField, occupant = Crate }

            "q" ->
                Space { kind = GoalField, occupant = Player moods }

            _ ->
                Block


isGoalField : GameElement -> Bool
isGoalField elm =
    case elm of
        Space { kind } ->
            kind == GoalField

        _ ->
            False


hasCrate : GameElement -> Bool
hasCrate elm =
    case elm of
        Space { occupant } ->
            occupant == Crate

        _ ->
            False


occupyWith : Occupant -> Occupyable -> GameElement
occupyWith occupant occupyable =
    Space { occupyable | occupant = occupant }


deoccupy : Occupyable -> GameElement
deoccupy occupyable =
    Space { occupyable | occupant = None }
