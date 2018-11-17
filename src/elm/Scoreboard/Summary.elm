module Scoreboard.Summary exposing (grandTotal, incYahtzeeBonus, upperBonus, yahtzeeBonus)

import Scoreboard.Model exposing (Model, ScoreKey(..), getScore, setScore)


incYahtzeeBonus : Model -> Model
incYahtzeeBonus model =
    setScore YahtzeeBonusCount (getScoreOrZero YahtzeeBonusCount model + 1) model


upperBonus : Model -> Int
upperBonus model =
    if upperTotal model >= 63 then
        35

    else
        0


yahtzeeBonus : Model -> Int
yahtzeeBonus model =
    100 * getScoreOrZero YahtzeeBonusCount model


upperTotal : Model -> Int
upperTotal model =
    getScoreOrZero Ones model
        + getScoreOrZero Twos model
        + getScoreOrZero Threes model
        + getScoreOrZero Fours model
        + getScoreOrZero Fives model
        + getScoreOrZero Sixes model


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


getScoreOrZero : ScoreKey -> Model -> Int
getScoreOrZero key model =
    Maybe.withDefault 0 <| getScore key model
