module Game.Scoreboard exposing (calcUpperBonus, calcUpperTotal, calcUpperTotalWithBonus, getScore, setScore)

import Dict
import Game.Types exposing (ScoreKey(..), Scoreboard)


getScore : ScoreKey -> Scoreboard -> Maybe Int
getScore key scoreboard =
    Dict.get (scoreKey key) scoreboard


setScore : ScoreKey -> Int -> Bool -> Scoreboard -> Scoreboard
setScore key score incYahtzeeBonus scoreboard =
    let
        newScoreboard =
            Dict.insert (scoreKey key) score scoreboard
    in
    if incYahtzeeBonus then
        Dict.update (scoreKey YahtzeeBonusCount) (\v -> Just (Maybe.withDefault 0 v + 1)) newScoreboard

    else
        newScoreboard


scoreKey : ScoreKey -> Int
scoreKey key =
    case key of
        Ones ->
            1

        Twos ->
            2

        Threes ->
            3

        Fours ->
            4

        Fives ->
            5

        Sixes ->
            6

        ThreeOfKind ->
            7

        FourOfKind ->
            8

        FullHouse ->
            9

        SmallStraight ->
            10

        LargeStraight ->
            11

        Yahtzee ->
            12

        Chance ->
            13

        YahtzeeBonusCount ->
            14


calcUpperBonus : Scoreboard -> Int
calcUpperBonus scoreboard =
    if calcUpperTotal scoreboard >= 63 then
        35

    else
        0


calcUpperTotal : Scoreboard -> Int
calcUpperTotal scoreboard =
    let
        score =
            \key -> Maybe.withDefault 0 (getScore key scoreboard)
    in
    score Ones + score Twos + score Threes + score Fours + score Fives + score Sixes


calcUpperTotalWithBonus : Scoreboard -> Int
calcUpperTotalWithBonus scoreboard =
    calcUpperTotal scoreboard + calcUpperBonus scoreboard
