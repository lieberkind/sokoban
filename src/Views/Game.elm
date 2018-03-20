module Views.Game exposing (..)


hello : String
hello =
    "World"


renderGame : Game -> Html msg
renderGame game =
    div
                            [ classList
                                [ ( "popup", True )
                                , ( "visible", Game.levelWon game )
                                ]
                            ]
                            [ p
                                []
                                [ text ("You completed level " ++ (Level.number lvl |> toString))
                                , br [] []
                                , text ("with " ++ (Level.moves lvl |> toString) ++ " moves")
                                , br [] []
                                , text ("and " ++ (Level.pushes lvl |> toString) ++ " pushes")
                                ]
                            , button
                                [ class "keyboard-button dismiss-popup" ]
                                [ text "OK" ]
                            , button
                                [ class "keyboard-button dismiss-popup", onClick AdvanceLevel ]
                                [ text "OK" ]
                            ]
                        , printGrid (Level.grid lvl)
