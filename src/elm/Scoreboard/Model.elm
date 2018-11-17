module Scoreboard.Model exposing (Bonus(..), Model, ScoreKey(..), defaultModel, fromList, getScore, isComplete, setScore, turn)

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


setScore : ScoreKey -> Int -> Model -> Model
setScore key score model =
    Dict.insert (scoreKeyToIndex key) score model


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
