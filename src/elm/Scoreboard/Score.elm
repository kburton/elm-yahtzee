module Scoreboard.Score exposing (options)

import Dict exposing (Dict)
import Scoreboard.Model exposing (Model, ScoreKey(..))


type alias FaceCounts =
    Dict Int Int


options : List Int -> Model -> ( Model, Bool )
options dice scoreboard =
    let
        fCounts =
            faceCounts dice

        counts =
            List.reverse <| List.sort <| Dict.values fCounts

        highestCount =
            Maybe.withDefault 0 <| List.head counts

        sum =
            List.sum dice

        yahtzeeScore =
            calcYahtzee highestCount

        isYahtzee =
            yahtzeeScore > 0

        yahtzeeWildcard =
            isYahtzee && yahtzeeWildcardAvailable dice scoreboard
    in
    ( Scoreboard.Model.fromList
        [ ( Ones, calcUpper 1 fCounts )
        , ( Twos, calcUpper 2 fCounts )
        , ( Threes, calcUpper 3 fCounts )
        , ( Fours, calcUpper 4 fCounts )
        , ( Fives, calcUpper 5 fCounts )
        , ( Sixes, calcUpper 6 fCounts )
        , ( ThreeOfKind, calcNOfKind 3 highestCount sum )
        , ( FourOfKind, calcNOfKind 4 highestCount sum )
        , ( FullHouse, calcFullHouse counts yahtzeeWildcard )
        , ( SmallStraight, calcSmallStraight fCounts yahtzeeWildcard )
        , ( LargeStraight, calcLargeStraight fCounts yahtzeeWildcard )
        , ( Yahtzee, yahtzeeScore )
        , ( Chance, sum )
        ]
    , yahtzeeWildcard
    )


faceCounts : List Int -> FaceCounts
faceCounts dice =
    List.foldl
        (\val acc -> Dict.update val (\cur -> Just (Maybe.withDefault 0 cur + 1)) acc)
        Dict.empty
        dice


yahtzeeWildcardAvailable : List Int -> Model -> Bool
yahtzeeWildcardAvailable dice scoreboard =
    let
        isScored key =
            Scoreboard.Model.getScore key scoreboard /= Nothing

        yahtzeeScored =
            isScored Yahtzee

        upperSectionUsed =
            case List.head dice of
                Just 1 ->
                    isScored Ones

                Just 2 ->
                    isScored Twos

                Just 3 ->
                    isScored Threes

                Just 4 ->
                    isScored Fours

                Just 5 ->
                    isScored Fives

                Just 6 ->
                    isScored Sixes

                _ ->
                    False

        lowerSectionAvailable =
            List.any (not << isScored) [ FullHouse, SmallStraight, LargeStraight ]
    in
    yahtzeeScored && upperSectionUsed && lowerSectionAvailable


calcUpper : Int -> FaceCounts -> Int
calcUpper face counts =
    (*) face <| Maybe.withDefault 0 <| Dict.get face counts


calcNOfKind : Int -> Int -> Int -> Int
calcNOfKind n highestCount sum =
    if highestCount >= n then
        sum

    else
        0


calcFullHouse : List Int -> Bool -> Int
calcFullHouse counts yahtzeeWildcard =
    if yahtzeeWildcard then
        25

    else
        case counts of
            3 :: 2 :: rest ->
                25

            _ ->
                0


calcSmallStraight : FaceCounts -> Bool -> Int
calcSmallStraight counts yahtzeeWildcard =
    if
        yahtzeeWildcard
            || List.all (\f -> Dict.member f counts) [ 1, 2, 3, 4 ]
            || List.all (\f -> Dict.member f counts) [ 2, 3, 4, 5 ]
            || List.all (\f -> Dict.member f counts) [ 3, 4, 5, 6 ]
    then
        30

    else
        0


calcLargeStraight : FaceCounts -> Bool -> Int
calcLargeStraight counts yahtzeeWildcard =
    if
        yahtzeeWildcard
            || List.all (\f -> Dict.member f counts) [ 1, 2, 3, 4, 5 ]
            || List.all (\f -> Dict.member f counts) [ 2, 3, 4, 5, 6 ]
    then
        40

    else
        0


calcYahtzee : Int -> Int
calcYahtzee highestCount =
    if highestCount == 5 then
        50

    else
        0
