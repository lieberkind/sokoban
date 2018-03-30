module Data.Cyclic exposing (Cyclic, fromElements, current, next)


type Cyclic a
    = Cyclic { beforeSel : List a, sel : a, afterSel : List a }


fromElements : a -> List a -> Cyclic a
fromElements sel afterSel =
    Cyclic { beforeSel = [], sel = sel, afterSel = afterSel }


current : Cyclic a -> a
current (Cyclic { sel }) =
    sel


next : Cyclic a -> Cyclic a
next (Cyclic { beforeSel, sel, afterSel }) =
    case ( beforeSel, sel, afterSel ) of
        -- (a) -> (a)
        ( [], sel, [] ) ->
            Cyclic { beforeSel = [], sel = sel, afterSel = [] }

        -- (a) b c -> a (b) c
        ( [], sel, y :: ys ) ->
            Cyclic { beforeSel = [ sel ], sel = y, afterSel = ys }

        -- a b (c) -> (a) b c
        ( x :: xs, sel, [] ) ->
            Cyclic { beforeSel = [], sel = x, afterSel = xs ++ [ sel ] }

        -- a b (c) d e -> a b c (d) e
        ( x :: xs, sel, y :: ys ) ->
            Cyclic { beforeSel = (x :: xs) ++ [ sel ], sel = y, afterSel = ys }
