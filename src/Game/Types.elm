module Game.Types exposing (Dice, Die, Face, Index, Model, Msg(..), ScoreKey(..), Scoreboard, currentGame, maxRolls, maxRollsReached, maxTurns, maxTurnsReached)

import Array exposing (Array)
import Dict exposing (Dict)


type alias Model =
    { games : List Scoreboard
    , turn : Int
    , roll : Int
    , dice : Dice
    , tutorialMode : Bool
    }


type Msg
    = Roll
    | SetFlips Index Int
    | Flip Index
    | NewFace Index Face
    | ToggleLock Index
    | Score ScoreKey
    | NewGame


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


type alias Scoreboard =
    Dict Int Int


type alias Index =
    Int


type alias Face =
    Int


type alias Dice =
    Array Die


type alias Die =
    { face : Face
    , flipsLeft : Int
    , locked : Bool
    }


maxRolls : Int
maxRolls =
    3


maxRollsReached : Model -> Bool
maxRollsReached model =
    model.roll > maxRolls


maxTurns : Int
maxTurns =
    13


maxTurnsReached : Model -> Bool
maxTurnsReached model =
    model.turn > maxTurns


currentGame : Model -> Scoreboard
currentGame model =
    case model.games of
        scoreboard :: rest ->
            scoreboard

        _ ->
            Dict.empty
