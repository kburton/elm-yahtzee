module View.Dice exposing (dice, exampleDice)

import Array
import Dice.Model exposing (..)
import Dice.Msg
import Html exposing (Html)
import Msg exposing (Msg)
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt


dice : Model -> Bool -> List (Html Msg)
dice model allowToggle =
    Array.toList <| Array.indexedMap (clickableDie allowToggle) model


type DieType
    = DieTypeLocked
    | DieTypeUnlocked
    | DieTypeExample
    | DieTypeExampleScored


clickableDie : Bool -> Index -> Die -> Html Msg
clickableDie allowToggle index dieModel =
    let
        dieType =
            if dieModel.locked then
                DieTypeLocked

            else
                DieTypeUnlocked

        msg =
            if allowToggle then
                Just (Msg.DiceMsg (Dice.Msg.ToggleLock index))

            else
                Nothing
    in
    die dieType dieModel.face msg


exampleDice : List ( Face, Bool ) -> List (Html Msg)
exampleDice faces =
    List.map (\( f, s ) -> exampleDie f s) faces


exampleDie : Face -> Bool -> Html Msg
exampleDie face isScoring =
    let
        dieType =
            if isScoring then
                DieTypeExampleScored

            else
                DieTypeExample
    in
    die dieType face Nothing


die : DieType -> Face -> Maybe Msg -> Html Msg
die dieType face msg =
    let
        ( evt, baseClass ) =
            case msg of
                Just m ->
                    ( [ SvgEvt.onClick m ], "die die--clickable" )

                Nothing ->
                    ( [], "die" )

        typeClass =
            case dieType of
                DieTypeLocked ->
                    "die--locked"

                DieTypeUnlocked ->
                    "die--unlocked"

                DieTypeExample ->
                    "die--example"

                DieTypeExampleScored ->
                    "die--example-scored"

        class =
            baseClass ++ " " ++ typeClass
    in
    Svg.svg
        ([ SvgAtt.viewBox "0 0 120 120", SvgAtt.class class ] ++ evt)
        (dieFace ++ spots face)


dieFace : List (Svg.Svg msg)
dieFace =
    [ Svg.rect
        [ SvgAtt.x "0"
        , SvgAtt.y "0"
        , SvgAtt.width "120"
        , SvgAtt.height "120"
        , SvgAtt.rx "25"
        , SvgAtt.ry "25"
        ]
        []
    ]


spots : Face -> List (Svg.Svg msg)
spots face =
    let
        smSpot =
            spot "12"

        mdSpot =
            spot "15"

        lgSpot =
            spot "20"
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


spot : String -> DieV -> DieH -> Html msg
spot r v h =
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
        , SvgAtt.class "die__spot"
        , SvgAtt.pointerEvents "none"
        ]
        []
