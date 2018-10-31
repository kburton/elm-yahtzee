module Game.View exposing (dice, scoreboard)

import Array
import Dict exposing (Dict)
import Game.Dice as Dice
import Game.Scoreboard as Scoreboard
import Game.Styles as Styles
import Game.Types as Types
import Html
import Html.Styled exposing (Html, a, div, table, td, text, th, tr)
import Html.Styled.Attributes exposing (css, href, style)
import Html.Styled.Events exposing (onClick)
import Svg.Styled as Svg
import Svg.Styled.Attributes as SvgAtt
import Svg.Styled.Events as SvgEvt


scoreboard : Types.Model -> Html Types.Msg
scoreboard model =
    div
        [ css Styles.scoreboardStyle ]
        [ scoreboardRow model Types.Ones "Aces"
        , scoreboardRow model Types.Twos "Twos"
        , scoreboardRow model Types.Threes "Threes"
        , scoreboardRow model Types.Fours "Fours"
        , scoreboardRow model Types.Fives "Fives"
        , scoreboardRow model Types.Sixes "Sixes"
        , derivedRow model Scoreboard.upperTotal "Upper score"
        , derivedRow model Scoreboard.upperBonus "Upper bonus"
        , derivedRow model Scoreboard.upperTotalWithBonus "Upper total"
        , scoreboardRow model Types.ThreeOfKind "3 of a kind"
        , scoreboardRow model Types.FourOfKind "4 of a kind"
        , scoreboardRow model Types.FullHouse "Full house"
        , scoreboardRow model Types.SmallStraight "Sm straight"
        , scoreboardRow model Types.LargeStraight "Lg straight"
        , scoreboardRow model Types.Yahtzee "Yahtzee"
        , scoreboardRow model Types.Chance "Chance"
        , yahtzeeBonusCountRow model "Yahtzee bonus"
        , derivedRow model Scoreboard.lowerTotalWithBonus "Lower total"
        , derivedRow model Scoreboard.upperTotalWithBonus "Upper total"
        , derivedRow model Scoreboard.grandTotal "Grand total"
        ]


scoreboardRow : Types.Model -> Types.ScoreKey -> String -> Html Types.Msg
scoreboardRow model key label =
    case model.games of
        game :: rest ->
            div
                [ css Styles.rowStyle ]
                [ div [ css Styles.scoreLabelStyle ] [ text label ]
                , case Scoreboard.getScore key game of
                    Nothing ->
                        if not (Dice.areRolling model.dice) && model.roll > 1 then
                            div
                                [ css Styles.scoreValueClickableStyle, onClick (Types.Score key) ]
                                [ a [] [ text <| String.fromInt <| Dice.calcScore key model.dice game ] ]

                        else
                            div
                                [ css Styles.scoreValueStyle ]
                                [ text "" ]

                    Just n ->
                        div
                            [ css Styles.scoreValueStyle ]
                            [ text <| String.fromInt n ]
                ]

        _ ->
            div [] []


derivedRow : Types.Model -> (Types.Scoreboard -> Int) -> String -> Html msg
derivedRow model fn label =
    case model.games of
        game :: rest ->
            div
                [ css Styles.derivedRowStyle ]
                [ div [ css Styles.scoreLabelStyle ] [ text label ]
                , div [ css Styles.scoreValueStyle ] [ text <| String.fromInt <| fn game ]
                ]

        _ ->
            div [] []


yahtzeeBonusCountRow : Types.Model -> String -> Html msg
yahtzeeBonusCountRow model label =
    case model.games of
        game :: rest ->
            div
                [ css Styles.derivedRowStyle ]
                [ div
                    [ css Styles.scoreLabelStyle ]
                    [ text label ]
                , div
                    [ css Styles.scoreValueStyle ]
                    [ text <| String.repeat (Maybe.withDefault 0 <| Scoreboard.getScore Types.YahtzeeBonusCount game) "x" ]
                ]

        _ ->
            div [] []


dice : Types.Model -> List (Html Types.Msg)
dice model =
    Array.toList <| Array.indexedMap die model.dice


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
    div
        [ css Styles.dieStyle
        , onClick attributes.msg
        ]
        [ Svg.svg
            [ SvgAtt.viewBox "0 0 120 120"
            , SvgAtt.style "height: 100%;"
            ]
            ([ Svg.rect
                [ SvgAtt.x "0"
                , SvgAtt.y "0"
                , SvgAtt.width "120"
                , SvgAtt.height "120"
                , SvgAtt.rx "25"
                , SvgAtt.ry "25"
                , SvgAtt.fill attributes.dieColor
                ]
                []
             ]
                ++ spots attributes.spotColor dieModel.face
            )
        ]


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
