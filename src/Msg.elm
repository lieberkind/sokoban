module Msg exposing (..)

import Data.Movement exposing (Direction)
import Keyboard exposing (KeyCode)


type Msg
    = Move Direction
    | UndoMove
    | UndoLevel
    | StartOver
    | KeyDown KeyCode
    | KeyUp KeyCode
    | AdvanceLevel
    | NoOp
