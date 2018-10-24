module Game.Dice exposing (calcScore)

import Array
import Dict exposing (Dict)
import Game.Types exposing (Dice, Face, ScoreKey(..))


getFaces : Dice -> List Int
getFaces dice =
    List.map .face <| Array.toList dice


getCounts : Dice -> Dict Face Int
getCounts dice =
    List.foldl
        (\val acc -> Dict.update val (\cur -> Just (Maybe.withDefault 0 cur + 1)) acc)
        Dict.empty
        (getFaces dice)


calcScore : ScoreKey -> Dice -> Int
calcScore key dice =
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
            calcFullHouse dice

        SmallStraight ->
            calcSmallStraight dice

        LargeStraight ->
            calcLargeStraight dice

        Yahtzee ->
            calcYahtzee dice

        Chance ->
            calcChance dice


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


calcFullHouse : Dice -> Int
calcFullHouse dice =
    let
        scores =
            List.sort <| Dict.values <| getCounts dice
    in
    case scores of
        2 :: 3 :: rest ->
            25

        _ ->
            0


calcSmallStraight : Dice -> Int
calcSmallStraight dice =
    let
        counts =
            getCounts dice
    in
    if
        List.all (\f -> Dict.member f counts) [ 1, 2, 3, 4 ]
            || List.all (\f -> Dict.member f counts) [ 2, 3, 4, 5 ]
            || List.all (\f -> Dict.member f counts) [ 3, 4, 5, 6 ]
    then
        30

    else
        0


calcLargeStraight : Dice -> Int
calcLargeStraight dice =
    let
        counts =
            getCounts dice
    in
    if
        List.all (\f -> Dict.member f counts) [ 1, 2, 3, 4, 5 ]
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
