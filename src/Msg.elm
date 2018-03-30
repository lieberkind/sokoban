module Msg exposing (..)

import Data.Movement exposing (Direction)
import Keyboard exposing (KeyCode)


type Msg
    = Move Direction
    | UndoMove
    | UndoLevel
    | RequestStartOverConfirmation
    | ConfirmStartOver
    | CancelStartOver
    | KeyDown KeyCode
    | KeyUp KeyCode
    | AdvanceLevel
    | NextPlayerSprite
    | NoOp
