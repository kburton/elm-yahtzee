module Dice.State exposing (init, subscriptions, update)

import Array
import Dice.Types
import Random
import Time
import Types


init : () -> ( Dice.Types.Model, Cmd Dice.Types.Msg )
init _ =
    ( Dice.Types.Model <| Array.repeat 5 (Dice.Types.Die 1 0 False)
    , Cmd.none
    )


update : Dice.Types.Msg -> Types.Model -> ( Dice.Types.Model, Cmd Dice.Types.Msg )
update msg model =
    let
        diceModel =
            model.dice

        getDie index =
            Maybe.withDefault (Dice.Types.Die 1 0 False) (Array.get index diceModel.dice)

        updateFace index face =
            (\d -> { diceModel | dice = Array.set index { d | face = face } diceModel.dice }) (getDie index)

        updateFlips index flips =
            (\d -> { diceModel | dice = Array.set index { d | flipsLeft = flips } diceModel.dice }) (getDie index)

        decrementFlips index =
            (\d -> { diceModel | dice = Array.set index { d | flipsLeft = d.flipsLeft - 1 } diceModel.dice }) (getDie index)

        toggleLock index =
            (\d -> { diceModel | dice = Array.set index { d | locked = not d.locked } diceModel.dice }) (getDie index)

        flip index =
            Random.generate (Dice.Types.NewFace index) (Random.int 1 6)
    in
    case msg of
        Dice.Types.SetFlips index flips ->
            ( updateFlips index flips
            , Cmd.none
            )

        Dice.Types.Flip index ->
            ( decrementFlips index
            , flip index
            )

        Dice.Types.NewFace index newFace ->
            ( updateFace index newFace
            , Cmd.none
            )

        Dice.Types.ToggleLock index ->
            ( if (getDie index).flipsLeft == 0 && model.game.roll > 1 then
                toggleLock index

              else
                diceModel
            , Cmd.none
            )


subscriptions : Dice.Types.Model -> Sub Dice.Types.Msg
subscriptions model =
    Sub.batch <| List.map (\( i, f ) -> Time.every (200 / toFloat f) (\t -> Dice.Types.Flip i)) (Dice.Types.rollingDice model)
