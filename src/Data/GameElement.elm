module Data.GameElement exposing (..)


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
    | Space { occupant : Maybe MovingObject, kind : SpaceType }


type alias Occupyable r =
    { r | occupant : Maybe MovingObject, kind : SpaceType }


fromString : String -> GameElement
fromString str =
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


isGoalField : GameElement -> Bool
isGoalField obj =
    case obj of
        Space { kind } ->
            case kind of
                GoalField ->
                    True

                _ ->
                    False

        _ ->
            False


hasCrate : GameElement -> Bool
hasCrate obj =
    case obj of
        Space { occupant } ->
            case occupant of
                Just Crate ->
                    True

                _ ->
                    False

        _ ->
            False


occupyWith : MovingObject -> Occupyable r -> GameElement
occupyWith obj r =
    Space { kind = r.kind, occupant = Just obj }


deoccupy : Occupyable r -> GameElement
deoccupy r =
    Space { kind = r.kind, occupant = Nothing }
