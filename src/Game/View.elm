module Game.View exposing (dice, rollDisplay, scoreboard)

import Array
import Dict exposing (Dict)
import Game.Dice as Dice
import Game.Scoreboard as Scoreboard
import Game.Types as Types
import Html exposing (Html, a, div, table, td, text, th, tr)
import Html.Attributes exposing (href, style)
import Html.Events exposing (onClick)
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt


rollDisplay : Types.Model -> String
rollDisplay model =
    if model.roll >= Types.maxRolls then
        "Final roll"

    else
        case model.roll of
            1 ->
                "First roll"

            2 ->
                "Second roll"

            n ->
                "Roll" ++ String.fromInt n


scoreboard : Types.Model -> Html Types.Msg
scoreboard model =
    table
        []
        [ scoreboardRow model Types.Ones "Aces"
        , scoreboardRow model Types.Twos "Twos"
        , scoreboardRow model Types.Threes "Threes"
        , scoreboardRow model Types.Fours "Fours"
        , scoreboardRow model Types.Fives "Fives"
        , scoreboardRow model Types.Sixes "Sixes"
        , derivedRow model Scoreboard.calcUpperTotal "Upper total"
        , derivedRow model Scoreboard.calcUpperBonus "Upper bonus"
        , scoreboardRow model Types.ThreeOfKind "3 of a kind"
        , scoreboardRow model Types.FourOfKind "4 of a kind"
        , scoreboardRow model Types.FullHouse "Full house"
        , scoreboardRow model Types.SmallStraight "Sm straight"
        , scoreboardRow model Types.LargeStraight "Lg straight"
        , scoreboardRow model Types.Yahtzee "Yahtzee"
        , scoreboardRow model Types.Chance "Chance"
        ]


scoreboardRow : Types.Model -> Types.ScoreKey -> String -> Html Types.Msg
scoreboardRow model key label =
    tr
        []
        ([ th [] [ text label ]
         ]
            ++ List.map
                (\game ->
                    td []
                        [ case Scoreboard.getScore key game of
                            Nothing ->
                                if (List.isEmpty <| Types.rollingDice model) && model.roll > 1 then
                                    a
                                        [ style "color" "green", style "cursor" "pointer", onClick (Types.Score key) ]
                                        [ text <| String.fromInt <| Dice.calcScore key model.dice ]

                                else
                                    text ""

                            Just n ->
                                text <| String.fromInt n
                        ]
                )
                model.games
        )


derivedRow : Types.Model -> (Types.Scoreboard -> Int) -> String -> Html Types.Msg
derivedRow model fn label =
    tr
        []
        ([ th [] [ text label ]
         ]
            ++ List.map
                (\game ->
                    td []
                        [ text <| String.fromInt <| fn game
                        ]
                )
                model.games
        )


dice : Types.Model -> Html Types.Msg
dice model =
    div []
        (Array.toList <| Array.indexedMap die model.dice)


type alias ViewDieAttributes =
    { dieColor : String
    , spotColor : String
    , msg : Types.Msg
    }


die : Types.Index -> Types.Die -> Html Types.Msg
die index dieModel =
    let
        attributes =
            case dieModel.locked of
                True ->
                    ViewDieAttributes "#440000" "#990000" (Types.ToggleLock index)

                False ->
                    ViewDieAttributes "#005500" "#00CC00" (Types.ToggleLock index)
    in
    Svg.svg
        [ SvgAtt.width "120"
        , SvgAtt.height "120"
        , SvgAtt.viewBox "0 0 120 120"
        , SvgAtt.style "float: left; display: block; margin: 0 1rem 1rem 0;"
        ]
        ([ Svg.rect
            [ SvgAtt.x "0"
            , SvgAtt.y "0"
            , SvgAtt.width "120"
            , SvgAtt.height "120"
            , SvgAtt.rx "25"
            , SvgAtt.ry "25"
            , SvgAtt.fill attributes.dieColor
            , SvgEvt.onClick attributes.msg
            ]
            []
         ]
            ++ spots attributes.spotColor dieModel.face
        )


spots : String -> Types.Face -> List (Svg.Svg Types.Msg)
spots color face =
    let
        smSpot =
            spot color "12"

        mdSpot =
            spot color "15"

        lgSpot =
            spot color "20"
    in
    case face of
        1 ->
            [ lgSpot M C ]

        2 ->
            [ mdSpot T L, mdSpot B R ]

        3 ->
            [ mdSpot T L, mdSpot M C, mdSpot B R ]

        4 ->
            [ mdSpot T L, mdSpot T R, mdSpot B L, mdSpot B R ]

        5 ->
            [ mdSpot T L, mdSpot T R, mdSpot M C, mdSpot B L, mdSpot B R ]

        6 ->
            [ smSpot T L, smSpot T R, smSpot M L, smSpot M R, smSpot B L, smSpot B R ]

        _ ->
            []


type DieV
    = T
    | M
    | B


type DieH
    = L
    | C
    | R


spot : String -> String -> DieV -> DieH -> Html msg
spot c r v h =
    let
        x =
            case h of
                L ->
                    "30"

                C ->
                    "60"

                R ->
                    "90"

        y =
            case v of
                T ->
                    "30"

                M ->
                    "60"

                B ->
                    "90"
    in
    Svg.circle
        [ SvgAtt.cx x
        , SvgAtt.cy y
        , SvgAtt.r r
        , SvgAtt.fill c
        , SvgAtt.pointerEvents "none"
        ]
        []
