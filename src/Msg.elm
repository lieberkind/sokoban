module Msg exposing (..)

import Data.Movement exposing (Direction)


type Msg
    = Move Direction
    | UndoMove
    | UndoLevel
    | RequestStartOverConfirmation
    | ConfirmStartOver
    | CancelStartOver
    | AdvanceLevel
    | UpdateSoko
    | NoOp
