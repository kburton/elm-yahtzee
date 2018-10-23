module Game.Types exposing (Die, Face, Index, Model, Msg(..), ScoreKey(..), activeDice, calcScore, defaultDice, getScore, maxRolls, maxRollsReached, maxTurns, rollingDice, setScore)

import Array exposing (Array)
import Dict exposing (Dict)


type alias Model =
    { games : List (Dict Int Int)
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
    | Score ScoreKey


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


type alias Index =
    Int


type alias Face =
    Int


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


getFaces : Model -> List Int
getFaces model =
    List.map .face <| Array.toList model.dice


getCounts : Model -> Dict Face Int
getCounts model =
    List.foldl
        (\val acc -> Dict.update val (\cur -> Just (Maybe.withDefault 0 cur + 1)) acc)
        Dict.empty
        (getFaces model)


getScore : ScoreKey -> Dict Int Int -> Maybe Int
getScore key game =
    Dict.get (scoreKey key) game


setScore : ScoreKey -> Int -> Dict Int Int -> Dict Int Int
setScore key score game =
    Dict.insert (scoreKey key) score game


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


calcScore : ScoreKey -> Model -> Int
calcScore key model =
    case key of
        Ones ->
            calcUpper 1 model

        Twos ->
            calcUpper 2 model

        Threes ->
            calcUpper 3 model

        Fours ->
            calcUpper 4 model

        Fives ->
            calcUpper 5 model

        Sixes ->
            calcUpper 6 model

        ThreeOfKind ->
            calcNOfKind 3 model

        FourOfKind ->
            calcNOfKind 4 model

        FullHouse ->
            calcFullHouse model

        SmallStraight ->
            calcSmallStraight model

        LargeStraight ->
            calcLargeStraight model

        Yahtzee ->
            calcYahtzee model

        Chance ->
            calcChance model


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
