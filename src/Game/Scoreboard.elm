module Game.Scoreboard exposing (calcUpperBonus, getScore, setScore)

import Dict
import Game.Types exposing (ScoreKey(..), Scoreboard)


getScore : ScoreKey -> Scoreboard -> Maybe Int
getScore key scoreboard =
    Dict.get (scoreKey key) scoreboard


setScore : ScoreKey -> Int -> Scoreboard -> Scoreboard
setScore key score scoreboard =
    Dict.insert (scoreKey key) score scoreboard


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


calcUpperBonus : Scoreboard -> Int
calcUpperBonus scoreboard =
    let
        score =
            \key -> Maybe.withDefault 0 (getScore key scoreboard)
    in
    if score Ones + score Twos + score Threes + score Fours + score Fives + score Sixes >= 63 then
        35

    else
        0
