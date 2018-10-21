module Game.Types exposing (Model, Msg(..), Scoreboard, maxRolls, maxRollsReached, newScoreboard)


type alias Model =
    { games : List Scoreboard
    , turn : Int
    , roll : Int
    }


type Msg
    = Roll


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


maxRolls : Int
maxRolls =
    3


maxRollsReached : Model -> Bool
maxRollsReached model =
    model.roll > maxRolls


newScoreboard : Scoreboard
newScoreboard =
    Scoreboard Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing 0
