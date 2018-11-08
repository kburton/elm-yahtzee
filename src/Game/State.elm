module Game.State exposing (init, subscriptions, update)

import Array
import Dict
import Game.Dice as Dice
import Game.Scoreboard as Scoreboard
import Game.Types as Types
import Ports
import Random
import Task
import Time


defaultModel : Types.Model
defaultModel =
    { scoreboard = Dict.empty
    , turn = 1
    , roll = 1
    , dice = Dice.default
    , tutorialMode = True
    , lastScoreKey = Nothing
    , previous = Nothing
    }


init : Maybe Ports.GameStateModel -> ( Types.Model, Cmd Types.Msg )
init gameState =
    case gameState of
        Just gs ->
            ( Ports.fromGameStateModel defaultModel gs, Cmd.none )

        Nothing ->
            ( defaultModel, Cmd.none )


update : Types.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg model =
    let
        getDie index =
            Maybe.withDefault (Types.Die 1 0 False) (Array.get index model.dice)

        roll index =
            Random.generate (Types.SetFlips index) (Random.int 8 20)

        flip index =
            Random.generate (Types.NewFace index) (Random.int 1 6)

        updateFace index face =
            (\d -> { model | dice = Array.set index { d | face = face, flipsLeft = d.flipsLeft - 1 } model.dice }) (getDie index)

        updateFlips index flips =
            (\d -> { model | dice = Array.set index { d | flipsLeft = flips } model.dice }) (getDie index)

        toggleLock index =
            (\d -> { model | dice = Array.set index { d | locked = not d.locked } model.dice }) (getDie index)
    in
    case msg of
        Types.Roll ->
            if Types.maxRollsReached model || Types.maxTurnsReached model then
                ( model, Cmd.none )

            else
                ( { model | roll = model.roll + 1, previous = Nothing }
                , Cmd.batch <| List.map (\( i, _ ) -> roll i) <| Dice.active model.dice
                )

        Types.SetFlips index flips ->
            ( updateFlips index flips, Cmd.none )

        Types.Flip index ->
            ( model, flip index )

        Types.NewFace index newFace ->
            let
                newModel =
                    updateFace index newFace
            in
            ( updateFace index newFace
            , if Dice.areRolling newModel.dice then
                Cmd.none

              else
                Ports.persistGameState <| Ports.toGameStateModel newModel
            )

        Types.ToggleLock index ->
            ( if (getDie index).flipsLeft == 0 && model.roll > 1 then
                toggleLock index

              else
                model
            , Cmd.none
            )

        Types.Score key ->
            let
                isYahtzee =
                    Dice.calcScore Types.Yahtzee model.dice model.scoreboard > 0

                incYahtzeeBonus =
                    isYahtzee && Maybe.withDefault 0 (Scoreboard.getScore Types.Yahtzee model.scoreboard) > 0

                newModel =
                    { model
                        | turn = model.turn + 1
                        , roll = 1
                        , scoreboard = Scoreboard.setScore key (Dice.calcScore key model.dice model.scoreboard) incYahtzeeBonus model.scoreboard
                        , dice = Dice.default
                        , tutorialMode = model.tutorialMode && model.turn < 2
                        , lastScoreKey = Just key
                        , previous = Just (Types.Previous model)
                    }
            in
            ( newModel
            , Cmd.batch
                ([ Ports.persistGameState <| Ports.toGameStateModel newModel ]
                    ++ (if Scoreboard.gameIsOver newModel.scoreboard then
                            [ Task.perform (Types.Persist newModel) Time.now ]

                        else
                            []
                       )
                )
            )

        Types.NewGame ->
            let
                newModel =
                    { model
                        | turn = 1
                        , roll = 1
                        , scoreboard = Dict.empty
                        , dice = Dice.default
                        , lastScoreKey = Nothing
                        , tutorialMode = False
                    }
            in
            ( newModel, Ports.persistGameState <| Ports.toGameStateModel newModel )

        Types.Undo ->
            case model.previous of
                Just (Types.Previous p) ->
                    ( p, Ports.persistGameState <| Ports.toGameStateModel p )

                Nothing ->
                    ( model, Cmd.none )

        Types.Persist m time ->
            ( model, Ports.persistCompletedGame <| Ports.toGameModel m time )

        Types.ShowHelp _ _ ->
            ( model, Cmd.none )


subscriptions : Types.Model -> Sub Types.Msg
subscriptions model =
    Sub.batch <| List.map (\( i, f ) -> Time.every (200 / toFloat f) (\t -> Types.Flip i)) (Dice.rolling model.dice)
