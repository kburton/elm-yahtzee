module Dice.State exposing (init, subscriptions, update)

import Array
import Dice.Types as Types
import Random
import Time


init : () -> ( Types.Model, Cmd Types.Msg )
init _ =
    ( Types.Model <| Array.repeat 5 (Types.Die 1 0 False)
    , Cmd.none
    )


update : Types.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg model =
    let
        getDie index =
            Maybe.withDefault (Types.Die 1 0 False) (Array.get index model.dice)

        updateFace index face =
            (\d -> { model | dice = Array.set index { d | face = face } model.dice }) (getDie index)

        updateFlips index flips =
            (\d -> { model | dice = Array.set index { d | flipsLeft = flips } model.dice }) (getDie index)

        decrementFlips index =
            (\d -> { model | dice = Array.set index { d | flipsLeft = d.flipsLeft - 1 } model.dice }) (getDie index)

        toggleLock index =
            (\d -> { model | dice = Array.set index { d | locked = not d.locked } model.dice }) (getDie index)

        roll index =
            Random.generate (Types.SetFlips index) (Random.int 8 25)

        flip index =
            Random.generate (Types.NewFace index) (Random.int 1 6)
    in
    case msg of
        Types.RollAll ->
            ( model
            , Cmd.batch <| List.map (\( i, _ ) -> roll i) <| Types.activeDice model
            )

        Types.SetFlips index flips ->
            ( updateFlips index flips
            , Cmd.none
            )

        Types.Flip index ->
            ( decrementFlips index
            , flip index
            )

        Types.NewFace index newFace ->
            ( updateFace index newFace
            , Cmd.none
            )

        Types.ToggleLock index ->
            ( if (getDie index).flipsLeft == 0 then
                toggleLock index

              else
                model
            , Cmd.none
            )


subscriptions : Types.Model -> Sub Types.Msg
subscriptions model =
    Sub.batch <| List.map (\( i, f ) -> Time.every (200 / toFloat f) (\t -> Types.Flip i)) (Types.rollingDice model)
