module Scoreboard.Model exposing (Bonus(..), Model, ScoreKey(..), defaultModel, fromList, getScore, grandTotal, incYahtzeeBonus, isComplete, setScore, turn, upperBonus, yahtzeeBonus)

import Dict exposing (Dict)


type alias Model =
    Dict Int Int


type ScoreKey
    = Ones
    | Twos
    | Threes
    | Fours
    | Fives
    | Sixes
    | ThreeOfKind
    | FourOfKind
    | FullHouse
    | SmallStraight
    | LargeStraight
    | Yahtzee
    | Chance
    | YahtzeeBonusCount


type Bonus
    = UpperSectionBonus
    | YahtzeeBonus


defaultModel : Model
defaultModel =
    Dict.empty


fromList : List ( ScoreKey, Int ) -> Model
fromList list =
    Dict.fromList <| List.map (\( k, v ) -> ( scoreKeyToIndex k, v )) list


isComplete : Model -> Bool
isComplete model =
    13 == (Dict.size <| Dict.remove (scoreKeyToIndex YahtzeeBonusCount) model)


turn : Model -> Int
turn model =
    1 + (Dict.size <| Dict.remove (scoreKeyToIndex YahtzeeBonusCount) model)


getScore : ScoreKey -> Model -> Maybe Int
getScore key model =
    Dict.get (scoreKeyToIndex key) model


getScoreOrZero : ScoreKey -> Model -> Int
getScoreOrZero key model =
    Maybe.withDefault 0 <| getScore key model


setScore : ScoreKey -> Int -> Model -> Model
setScore key score model =
    Dict.insert (scoreKeyToIndex key) score model


incYahtzeeBonus : Model -> Model
incYahtzeeBonus model =
    Dict.update (scoreKeyToIndex YahtzeeBonusCount) (\v -> Just (Maybe.withDefault 0 v + 1)) model


upperBonus : Model -> Int
upperBonus model =
    if upperTotal model >= 63 then
        35

    else
        0


upperTotal : Model -> Int
upperTotal model =
    getScoreOrZero Ones model
        + getScoreOrZero Twos model
        + getScoreOrZero Threes model
        + getScoreOrZero Fours model
        + getScoreOrZero Fives model
        + getScoreOrZero Sixes model


yahtzeeBonus : Model -> Int
yahtzeeBonus model =
    100 * getScoreOrZero YahtzeeBonusCount model


lowerTotal : Model -> Int
lowerTotal model =
    getScoreOrZero ThreeOfKind model
        + getScoreOrZero FourOfKind model
        + getScoreOrZero FullHouse model
        + getScoreOrZero SmallStraight model
        + getScoreOrZero LargeStraight model
        + getScoreOrZero Yahtzee model
        + getScoreOrZero Chance model


grandTotal : Model -> Int
grandTotal model =
    upperTotal model + upperBonus model + lowerTotal model + yahtzeeBonus model


scoreKeyToIndex : ScoreKey -> Int
scoreKeyToIndex key =
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
