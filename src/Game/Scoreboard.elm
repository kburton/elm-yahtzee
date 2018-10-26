module Game.Scoreboard exposing (gameIsOver, getScore, grandTotal, isComplete, lowerTotalWithBonus, setScore, upperBonus, upperTotal, upperTotalWithBonus)

import Dict
import Game.Types exposing (ScoreKey(..), Scoreboard)
import Set exposing (Set)


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


isComplete : Scoreboard -> Bool
isComplete scoreboard =
    Set.isEmpty <| Set.diff (Set.fromList <| List.range 1 13) (Set.fromList <| Dict.keys scoreboard)


gameIsOver : Scoreboard -> Bool
gameIsOver =
    isComplete


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


upperBonus : Scoreboard -> Int
upperBonus scoreboard =
    if upperTotal scoreboard >= 63 then
        35

    else
        0


upperTotal : Scoreboard -> Int
upperTotal scoreboard =
    let
        score =
            \key -> Maybe.withDefault 0 (getScore key scoreboard)
    in
    score Ones + score Twos + score Threes + score Fours + score Fives + score Sixes


upperTotalWithBonus : Scoreboard -> Int
upperTotalWithBonus scoreboard =
    upperTotal scoreboard + upperBonus scoreboard


yahtzeeBonus : Scoreboard -> Int
yahtzeeBonus scoreboard =
    100 * Maybe.withDefault 0 (getScore YahtzeeBonusCount scoreboard)


lowerTotalWithBonus : Scoreboard -> Int
lowerTotalWithBonus scoreboard =
    let
        score =
            \key -> Maybe.withDefault 0 (getScore key scoreboard)
    in
    score ThreeOfKind
        + score FourOfKind
        + score FullHouse
        + score SmallStraight
        + score LargeStraight
        + score Yahtzee
        + score Chance
        + yahtzeeBonus scoreboard


grandTotal : Scoreboard -> Int
grandTotal scoreboard =
    upperTotalWithBonus scoreboard + lowerTotalWithBonus scoreboard
