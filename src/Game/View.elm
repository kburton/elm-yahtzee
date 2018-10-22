module Game.View exposing (dice, rollDisplay, scoreboard)

import Array
import Game.Types as Types
import Html exposing (Html, div, table, td, text, th, tr)
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
        [ scoreboardRowMaybeInt model.games "Aces" .ones (Types.calcUpper 1 model)
        , scoreboardRowMaybeInt model.games "Twos" .twos (Types.calcUpper 2 model)
        , scoreboardRowMaybeInt model.games "Threes" .threes (Types.calcUpper 3 model)
        , scoreboardRowMaybeInt model.games "Fours" .fours (Types.calcUpper 4 model)
        , scoreboardRowMaybeInt model.games "Fives" .fives (Types.calcUpper 5 model)
        , scoreboardRowMaybeInt model.games "Sixes" .sixes (Types.calcUpper 6 model)
        , scoreboardRowMaybeInt model.games "3 of a kind" .threeOfKind 0
        , scoreboardRowMaybeInt model.games "4 of a kind" .fourOfKind 0
        , scoreboardRowMaybeInt model.games "Full house" .fullHouse 0
        , scoreboardRowMaybeInt model.games "Sm straight" .smallStraight 0
        , scoreboardRowMaybeInt model.games "Lg straight" .largeStraight 0
        , scoreboardRowMaybeInt model.games "Yahtzee" .yahtzee 0
        , scoreboardRowMaybeInt model.games "Chance" .chance 0
        , scoreboardRowInt model.games "Yahtzee bonus" .yahtzeeBonusCount
        ]


scoreboardRowMaybeInt : List Types.Scoreboard -> String -> (Types.Scoreboard -> Maybe Int) -> Int -> Html msg
scoreboardRowMaybeInt games label field poss =
    tr
        []
        ([ th [] [ text label ]
         ]
            ++ List.map
                (\g ->
                    td []
                        [ text <|
                            case field g of
                                Nothing ->
                                    String.fromInt poss

                                Just n ->
                                    String.fromInt n
                        ]
                )
                games
        )


scoreboardRowInt : List Types.Scoreboard -> String -> (Types.Scoreboard -> Int) -> Html msg
scoreboardRowInt games label field =
    tr
        []
        ([ th [] [ text label ]
         ]
            ++ List.map (\g -> td [] [ text (String.fromInt (field g)) ]) games
        )


dice : Types.Model -> Html Types.Msg
dice model =
    div []
        (Array.toList <| Array.indexedMap (\i d -> die i d) model.dice)


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
