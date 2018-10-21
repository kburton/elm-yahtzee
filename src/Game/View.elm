module Game.View exposing (rollDisplay, scoreboard)

import Game.Types as Types
import Html exposing (Html, table, td, text, th, tr)


rollDisplay : Types.Model -> String
rollDisplay model =
    if model.roll >= Types.maxRolls then
        "Final roll"

    else
        case model.roll of
            1 ->
                "First roll"

            2 ->
                "Second roll"

            n ->
                "Roll" ++ String.fromInt n


scoreboard : Types.Model -> Html Types.Msg
scoreboard model =
    table
        []
        [ scoreboardRowMaybeInt model.games "Aces" .ones
        , scoreboardRowMaybeInt model.games "Twos" .twos
        , scoreboardRowMaybeInt model.games "Threes" .threes
        , scoreboardRowMaybeInt model.games "Fours" .fours
        , scoreboardRowMaybeInt model.games "Fives" .fives
        , scoreboardRowMaybeInt model.games "Sixes" .sixes
        , scoreboardRowMaybeInt model.games "3 of a kind" .threeOfKind
        , scoreboardRowMaybeInt model.games "4 of a kind" .fourOfKind
        , scoreboardRowMaybeInt model.games "Full house" .fullHouse
        , scoreboardRowMaybeInt model.games "Sm straight" .smallStraight
        , scoreboardRowMaybeInt model.games "Lg straight" .largeStraight
        , scoreboardRowMaybeInt model.games "Yahtzee" .yahtzee
        , scoreboardRowMaybeInt model.games "Chance" .chance
        , scoreboardRowInt model.games "Yahtzee bonus" .yahtzeeBonusCount
        ]


scoreboardRowMaybeInt : List Types.Scoreboard -> String -> (Types.Scoreboard -> Maybe Int) -> Html msg
scoreboardRowMaybeInt games label field =
    tr
        []
        ([ th [] [ text label ]
         ]
            ++ List.map
                (\g ->
                    td []
                        [ text <|
                            case field g of
                                Nothing ->
                                    ""

                                Just n ->
                                    String.fromInt n
                        ]
                )
                games
        )


scoreboardRowInt : List Types.Scoreboard -> String -> (Types.Scoreboard -> Int) -> Html msg
scoreboardRowInt games label field =
    tr
        []
        ([ th [] [ text label ]
         ]
            ++ List.map (\g -> td [] [ text (String.fromInt (field g)) ]) games
        )
