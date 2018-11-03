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
        [ scoreboardRow model Types.Ones "Aces" "Sum of ones"
        , scoreboardRow model Types.Twos "Twos" "Sum of twos"
        , scoreboardRow model Types.Threes "Threes" "Sum of threes"
        , scoreboardRow model Types.Fours "Fours" "Sum of fours"
        , scoreboardRow model Types.Fives "Fives" "Sum of fives"
        , scoreboardBonusRow model Types.Sixes Scoreboard.upperBonus "Sixes" "Sum of sixes"
        , scoreboardDivider
        , scoreboardRow model Types.ThreeOfKind "3 of a kind" "Sum of all dice"
        , scoreboardRow model Types.FourOfKind "4 of a kind" "Sum of all dice"
        , scoreboardRow model Types.FullHouse "Full house" "25 points"
        , scoreboardRow model Types.SmallStraight "Sm straight" "30 points"
        , scoreboardRow model Types.LargeStraight "Lg straight" "40 points"
        , scoreboardBonusRow model Types.Yahtzee Scoreboard.yahtzeeBonus "Yahtzee" "50 points"
        , scoreboardRow model Types.Chance "Chance" "Sum of all dice"
        ]


scoreboardRow : Types.Model -> Types.ScoreKey -> String -> String -> Html Types.Msg
scoreboardRow model key label info =
    case model.games of
        game :: rest ->
            div
                [ css Styles.rowStyle ]
                [ scoreLabel label
                , scoreInfo info
                , scoreValue model key game
                ]

        _ ->
            div [] []


scoreboardBonusRow : Types.Model -> Types.ScoreKey -> (Types.Scoreboard -> Int) -> String -> String -> Html Types.Msg
scoreboardBonusRow model key bonusFn label info =
    case model.games of
        game :: rest ->
            let
                bonus =
                    bonusFn game
            in
            if bonus == 0 then
                scoreboardRow model key label info

            else
                div
                    [ css Styles.rowStyle ]
                    [ scoreLabel label
                    , scoreBonus bonus
                    , scoreValue model key game
                    ]

        _ ->
            div [] []


scoreboardDivider : Html msg
scoreboardDivider =
    div [ css Styles.scoreboardDividerStyle ] []


scoreLabel : String -> Html Types.Msg
scoreLabel label =
    div [ css Styles.scoreLabelStyle ] [ text label ]


scoreInfo : String -> Html Types.Msg
scoreInfo info =
    div [ css Styles.scoreInfoStyle ] [ text info ]


scoreBonus : Int -> Html Types.Msg
scoreBonus bonus =
    div [ css Styles.scoreBonusStyle ] [ text <| "BONUS " ++ String.fromInt bonus ]


scoreValue : Types.Model -> Types.ScoreKey -> Types.Scoreboard -> Html Types.Msg
scoreValue model key game =
    case Scoreboard.getScore key game of
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
