module Dice.State exposing (init, subscriptions, update)

import Array
import Dice.Model exposing (..)
import Dice.Msg exposing (..)
import Ports
import Random
import Time


init : List Die -> ( Model, Cmd Msg )
init persistedDice =
    let
        validDice =
            List.filter
                (\d -> d.face >= 1 && d.face <= 6)
                persistedDice
    in
    if List.length validDice == 5 then
        ( Array.fromList validDice, Cmd.none )

    else
        ( defaultModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        roll index =
            Random.generate (SetFlips index) (Random.int 8 20)
    in
    case msg of
        Roll ->
            ( model
            , Cmd.batch <| List.map (roll << Tuple.first) (active model)
            )

        SetFlips index flips ->
            let
                die =
                    dieAt index model
            in
            ( Array.set index { die | flipsLeft = flips } model
            , Cmd.none
            )

        Flip index ->
            ( model
            , Random.generate (NewFace index) (Random.int 1 6)
            )

        NewFace index face ->
            let
                die =
                    dieAt index model
            in
            ( Array.set index { die | face = face, flipsLeft = die.flipsLeft - 1 } model, Cmd.none )

        ToggleLock index ->
            let
                die =
                    dieAt index model
            in
            ( Array.set index { die | locked = not die.locked } model
            , Cmd.none
            )

        Reset ->
            ( defaultModel, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch <|
        List.map
            (\( i, d ) -> Time.every (200 / toFloat d.flipsLeft) (\_ -> Flip i))
            (rolling model)
