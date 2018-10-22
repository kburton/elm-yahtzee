module Game.Types exposing (Die, Face, Index, Model, Msg(..), Scoreboard, activeDice, calcChance, calcFullHouse, calcLargeStraight, calcNOfKind, calcSmallStraight, calcUpper, calcYahtzee, maxRolls, maxRollsReached, maxTurns, newScoreboard, rollingDice)

import Array exposing (Array)
import Dict exposing (Dict)


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


getFaces : Model -> List Int
getFaces model =
    List.map .face <| Array.toList model.dice


getCounts : Model -> Dict Face Int
getCounts model =
    List.foldl
        (\val acc -> Dict.update val (\cur -> Just (Maybe.withDefault 0 cur + 1)) acc)
        Dict.empty
        (getFaces model)


calcUpper : Face -> Model -> Int
calcUpper face model =
    face * (Array.length <| Array.filter (\d -> d.face == face) model.dice)


calcNOfKind : Int -> Model -> Int
calcNOfKind n model =
    let
        matches =
            List.filter (\count -> count >= n) <| Dict.values <| getCounts model
    in
    if List.length matches == 0 then
        0

    else
        List.sum <| getFaces model


calcFullHouse : Model -> Int
calcFullHouse model =
    let
        scores =
            List.sort <| Dict.values <| getCounts model
    in
    case scores of
        a :: b :: rest ->
            if a == 2 && b == 3 then
                25

            else
                0

        _ ->
            0


calcSmallStraight : Model -> Int
calcSmallStraight model =
    let
        counts =
            getCounts model
    in
    if
        List.all (\f -> Dict.member f counts) [ 1, 2, 3, 4 ]
            || List.all (\f -> Dict.member f counts) [ 2, 3, 4, 5 ]
            || List.all (\f -> Dict.member f counts) [ 3, 4, 5, 6 ]
    then
        30

    else
        0


calcLargeStraight : Model -> Int
calcLargeStraight model =
    let
        counts =
            getCounts model
    in
    if
        List.all (\f -> Dict.member f counts) [ 1, 2, 3, 4, 5 ]
            || List.all (\f -> Dict.member f counts) [ 2, 3, 4, 5, 6 ]
    then
        40

    else
        0


calcYahtzee : Model -> Int
calcYahtzee model =
    if calcNOfKind 5 model == 0 then
        0

    else
        50


calcChance : Model -> Int
calcChance model =
    List.sum <| getFaces model
