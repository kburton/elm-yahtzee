module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Array exposing (Array)
import Browser
import Html exposing (Html, a, button, div, h1, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Process exposing (sleep)
import Random
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt
import Time
import Tuple exposing (first)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Die =
    { face : Face
    , flipsLeft : Int
    , locked : Bool
    }


type alias Index =
    Int


type alias Face =
    Int


type alias Model =
    { dice : Array Die
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model <| Array.repeat 5 (Die 1 0 False)
    , Cmd.none
    )



-- UPDATE


type Msg
    = RollAll
    | SetFlips Index Int
    | Flip Index
    | NewFace Index Face
    | ToggleLock Index


activeDice : Model -> List ( Index, Die )
activeDice model =
    Array.toList <| Array.filter (\( i, d ) -> not d.locked) <| Array.indexedMap (\i d -> ( i, d )) model.dice


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        getDie index =
            Maybe.withDefault (Die 1 0 False) (Array.get index model.dice)

        updateFace index face =
            (\d -> { model | dice = Array.set index { d | face = face } model.dice }) (getDie index)

        updateFlips index flips =
            (\d -> { model | dice = Array.set index { d | flipsLeft = flips } model.dice }) (getDie index)

        decrementFlips index =
            (\d -> { model | dice = Array.set index { d | flipsLeft = d.flipsLeft - 1 } model.dice }) (getDie index)

        toggleLock index =
            (\d -> { model | dice = Array.set index { d | locked = not d.locked } model.dice }) (getDie index)

        roll index =
            Random.generate (SetFlips index) (Random.int 8 25)

        flip index =
            Random.generate (NewFace index) (Random.int 1 6)
    in
    case msg of
        RollAll ->
            ( model
            , Cmd.batch <| List.map (\( i, _ ) -> roll i) <| activeDice model
            )

        SetFlips index flips ->
            ( updateFlips index flips
            , Cmd.none
            )

        Flip index ->
            ( decrementFlips index
            , flip index
            )

        NewFace index newFace ->
            ( updateFace index newFace
            , Cmd.none
            )

        ToggleLock index ->
            ( if (getDie index).flipsLeft == 0 then
                toggleLock index

              else
                model
            , Cmd.none
            )



-- SUBSCRIPTIONS


rollingDice : Model -> List ( Index, Int )
rollingDice model =
    Array.toList <| Array.filter (\( i, f ) -> f > 0) <| Array.indexedMap (\i d -> ( i, d.flipsLeft )) model.dice


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch <| List.map (\( i, f ) -> Time.every (200 / toFloat f) (\t -> Flip i)) (rollingDice model)



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewControls
        , viewDice model
        ]


viewControls : Html Msg
viewControls =
    div [ style "margin-bottom" "1rem" ]
        [ button
            [ onClick RollAll
            , style "font-size" "2rem"
            , style "margin-right" "1rem"
            ]
            [ text "Roll all" ]
        ]


viewDice : Model -> Html Msg
viewDice model =
    div []
        (Array.toList <| Array.indexedMap (\i d -> viewDie i d) model.dice)


type alias ViewDieAttributes =
    { dieColor : String
    , spotColor : String
    , msg : Msg
    }


viewDie : Index -> Die -> Html Msg
viewDie index die =
    let
        attributes =
            case die.locked of
                True ->
                    ViewDieAttributes "#440000" "#990000" (ToggleLock index)

                False ->
                    ViewDieAttributes "#005500" "#00CC00" (ToggleLock index)
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
            ++ spots attributes.spotColor die.face
        )


spots : String -> Face -> List (Svg.Svg Msg)
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
