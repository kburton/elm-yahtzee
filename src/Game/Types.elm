module Game.Types exposing (Die, Face, Index, Model, Msg(..), Scoreboard, activeDice, calcUpper, maxRolls, maxRollsReached, maxTurns, newScoreboard, rollingDice)

import Array exposing (Array)


type alias Model =
    { games : List Scoreboard
    , turn : Int
    , roll : Int
    , dice : Array Die
    }


type Msg
    = Roll
    | SetFlips Index Int
    | Flip Index
    | NewFace Index Face
    | ToggleLock Index


type alias Scoreboard =
    { ones : Maybe Int
    , twos : Maybe Int
    , threes : Maybe Int
    , fours : Maybe Int
    , fives : Maybe Int
    , sixes : Maybe Int
    , threeOfKind : Maybe Int
    , fourOfKind : Maybe Int
    , fullHouse : Maybe Int
    , smallStraight : Maybe Int
    , largeStraight : Maybe Int
    , yahtzee : Maybe Int
    , chance : Maybe Int
    , yahtzeeBonusCount : Int
    }


type alias Index =
    Int


type alias Face =
    Int


type alias Die =
    { face : Face
    , flipsLeft : Int
    , locked : Bool
    }


newScoreboard : Scoreboard
newScoreboard =
    Scoreboard Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing 0


maxRolls : Int
maxRolls =
    3


maxRollsReached : Model -> Bool
maxRollsReached model =
    model.roll > maxRolls


maxTurns : Int
maxTurns =
    13


activeDice : Model -> List ( Index, Die )
activeDice model =
    Array.toList <| Array.filter (\( i, d ) -> not d.locked) <| Array.indexedMap (\i d -> ( i, d )) model.dice


rollingDice : Model -> List ( Index, Int )
rollingDice model =
    Array.toList <| Array.filter (\( i, f ) -> f > 0) <| Array.indexedMap (\i d -> ( i, d.flipsLeft )) model.dice


calcUpper : Face -> Model -> Int
calcUpper face model =
    face * (Array.length <| Array.filter (\d -> d.face == face) model.dice)
