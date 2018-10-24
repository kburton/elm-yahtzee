module Game.Types exposing (Dice, Die, Face, Index, Model, Msg(..), ScoreKey(..), Scoreboard, activeDice, defaultDice, maxRolls, maxRollsReached, maxTurns, rollingDice)

import Array exposing (Array)
import Dict exposing (Dict)


type alias Model =
    { games : List Scoreboard
    , turn : Int
    , roll : Int
    , dice : Dice
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


defaultDice : Array Die
defaultDice =
    Array.repeat 5 (Die 1 0 False)


activeDice : Model -> List ( Index, Die )
activeDice model =
    Array.toList <| Array.filter (\( i, d ) -> not d.locked) <| Array.indexedMap (\i d -> ( i, d )) model.dice


rollingDice : Model -> List ( Index, Int )
rollingDice model =
    Array.toList <| Array.filter (\( i, f ) -> f > 0) <| Array.indexedMap (\i d -> ( i, d.flipsLeft )) model.dice
