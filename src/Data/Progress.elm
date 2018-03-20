module Data.Progress exposing (Progress)


type alias Progress =
    { levelNumber : Int
    , totalMoves : Int
    , totalPushes : Int
    }
