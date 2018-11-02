module Game.Dice exposing (active, areRolling, calcScore, default, isYahtzeeWildcard, rolling)

import Array
import Dict exposing (Dict)
import Game.Scoreboard
import Game.Types exposing (Dice, Die, Face, Index, ScoreKey(..), Scoreboard)


default : Dice
default =
    Array.repeat 5 (Die 1 0 False)


active : Dice -> List ( Index, Die )
active dice =
    Array.toList <| Array.filter (\( i, d ) -> not d.locked) <| Array.indexedMap (\i d -> ( i, d )) dice


rolling : Dice -> List ( Index, Int )
rolling dice =
    Array.toList <| Array.filter (\( i, f ) -> f > 0) <| Array.indexedMap (\i d -> ( i, d.flipsLeft )) dice


areRolling : Dice -> Bool
areRolling dice =
    not <| Array.isEmpty <| Array.filter (\d -> d.flipsLeft > 0) dice


getFaces : Dice -> List Int
getFaces dice =
    List.map .face <| Array.toList dice


getCounts : Dice -> Dict Face Int
getCounts dice =
    List.foldl
        (\val acc -> Dict.update val (\cur -> Just (Maybe.withDefault 0 cur + 1)) acc)
        Dict.empty
        (getFaces dice)


calcScore : ScoreKey -> Dice -> Scoreboard -> Int
calcScore key dice scoreboard =
    let
        yahtzeeWildcard =
            isYahtzeeWildcard dice scoreboard
    in
    case key of
        Ones ->
            calcUpper 1 dice

        Twos ->
            calcUpper 2 dice

        Threes ->
            calcUpper 3 dice

        Fours ->
            calcUpper 4 dice

        Fives ->
            calcUpper 5 dice

        Sixes ->
            calcUpper 6 dice

        ThreeOfKind ->
            calcNOfKind 3 dice

        FourOfKind ->
            calcNOfKind 4 dice

        FullHouse ->
            calcFullHouse dice yahtzeeWildcard

        SmallStraight ->
            calcSmallStraight dice yahtzeeWildcard

        LargeStraight ->
            calcLargeStraight dice yahtzeeWildcard

        Yahtzee ->
            calcYahtzee dice

        Chance ->
            calcChance dice

        YahtzeeBonusCount ->
            0


isYahtzeeWildcard : Dice -> Scoreboard -> Bool
isYahtzeeWildcard dice scoreboard =
    let
        isScored key =
            Game.Scoreboard.getScore key scoreboard /= Nothing

        yahtzeeScore =
            calcYahtzee dice

        isYahtzee =
            yahtzeeScore > 0

        yahtzeeScored =
            isScored Yahtzee

        upperSectionUsed =
            case getFaces dice of
                1 :: rest ->
                    isScored Ones

                2 :: rest ->
                    isScored Twos

                3 :: rest ->
                    isScored Threes

                4 :: rest ->
                    isScored Fours

                5 :: rest ->
                    isScored Fives

                6 :: rest ->
                    isScored Sixes

                _ ->
                    False

        yahtzeeWildcard =
            isYahtzee && yahtzeeScored && upperSectionUsed
    in
    yahtzeeWildcard


calcUpper : Face -> Dice -> Int
calcUpper face dice =
    face * (Array.length <| Array.filter (\d -> d.face == face) dice)


calcNOfKind : Int -> Dice -> Int
calcNOfKind n dice =
    let
        matches =
            List.filter (\count -> count >= n) <| Dict.values <| getCounts dice
    in
    if List.length matches == 0 then
        0

    else
        List.sum <| getFaces dice


calcFullHouse : Dice -> Bool -> Int
calcFullHouse dice yahtzeeWildcard =
    let
        scores =
            List.sort <| Dict.values <| getCounts dice
    in
    if yahtzeeWildcard then
        25

    else
        case scores of
            2 :: 3 :: rest ->
                25

            _ ->
                0


calcSmallStraight : Dice -> Bool -> Int
calcSmallStraight dice yahtzeeWildcard =
    let
        counts =
            getCounts dice
    in
    if
        yahtzeeWildcard
            || List.all (\f -> Dict.member f counts) [ 1, 2, 3, 4 ]
            || List.all (\f -> Dict.member f counts) [ 2, 3, 4, 5 ]
            || List.all (\f -> Dict.member f counts) [ 3, 4, 5, 6 ]
    then
        30

    else
        0


calcLargeStraight : Dice -> Bool -> Int
calcLargeStraight dice yahtzeeWildcard =
    let
        counts =
            getCounts dice
    in
    if
        yahtzeeWildcard
            || List.all (\f -> Dict.member f counts) [ 1, 2, 3, 4, 5 ]
            || List.all (\f -> Dict.member f counts) [ 2, 3, 4, 5, 6 ]
    then
        40

    else
        0


calcYahtzee : Dice -> Int
calcYahtzee dice =
    if calcNOfKind 5 dice == 0 then
        0

    else
        50


calcChance : Dice -> Int
calcChance dice =
    List.sum <| getFaces dice
