module Game.State exposing (init, subscriptions, update)

import Array
import Dict
import Game.Dice as Dice
import Game.Scoreboard as Scoreboard
import Game.Types as Types
import Random
import Time


init : () -> ( Types.Model, Cmd Types.Msg )
init _ =
    ( { games = [ Dict.empty ]
      , turn = 1
      , roll = 1
      , dice = Types.defaultDice
      }
    , Cmd.none
    )


update : Types.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg model =
    let
        getDie index =
            Maybe.withDefault (Types.Die 1 0 False) (Array.get index model.dice)

        roll index =
            Random.generate (Types.SetFlips index) (Random.int 8 25)

        flip index =
            Random.generate (Types.NewFace index) (Random.int 1 6)

        updateFace index face =
            (\d -> { model | dice = Array.set index { d | face = face } model.dice }) (getDie index)

        updateFlips index flips =
            (\d -> { model | dice = Array.set index { d | flipsLeft = flips } model.dice }) (getDie index)

        decrementFlips index =
            (\d -> { model | dice = Array.set index { d | flipsLeft = d.flipsLeft - 1 } model.dice }) (getDie index)

        toggleLock index =
            (\d -> { model | dice = Array.set index { d | locked = not d.locked } model.dice }) (getDie index)
    in
    case msg of
        Types.Roll ->
            if Types.maxRollsReached model then
                ( model, Cmd.none )

            else
                ( { model | roll = model.roll + 1 }
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
            ( if (getDie index).flipsLeft == 0 && model.roll > 1 then
                toggleLock index

              else
                model
            , Cmd.none
            )

        Types.Score key ->
            case model.games of
                currentScoreboard :: finishedScoreboards ->
                    ( { model
                        | turn = model.turn + 1
                        , roll = 1
                        , games = Scoreboard.setScore key (Dice.calcScore key model.dice) currentScoreboard :: finishedScoreboards
                        , dice = Types.defaultDice
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        Types.NewGame ->
            ( { model
                | turn = 1
                , roll = 1
                , games = Dict.empty :: model.games
                , dice = Types.defaultDice
              }
            , Cmd.none
            )


subscriptions : Types.Model -> Sub Types.Msg
subscriptions model =
    Sub.batch <| List.map (\( i, f ) -> Time.every (200 / toFloat f) (\t -> Types.Flip i)) (Types.rollingDice model)
