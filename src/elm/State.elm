module State exposing (init, subscriptions, update)

import Array
import Browser.Dom
import Browser.Events
import Dice.Model
import Dice.Msg
import Dice.State
import Dict
import Html
import Model exposing (..)
import Msg exposing (..)
import Ports
import Scoreboard.Model
import Scoreboard.Msg
import Scoreboard.State
import Task
import Time
import Update.Extra exposing (andThen)
import View.Help


init : Maybe Ports.Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( gameStateModel, history ) =
            case flags of
                Just f ->
                    ( f.gameState, f.history )

                Nothing ->
                    ( Nothing, Nothing )

        ( gamesPlayed, highScore ) =
            case history of
                Just h ->
                    ( List.length h, Maybe.withDefault 0 <| List.maximum <| List.map .g h )

                Nothing ->
                    ( 0, 0 )

        ( persistedScoreboard, persistedDice, roll ) =
            case gameStateModel of
                Just m ->
                    ( m.scoreboard, m.dice, m.roll )

                Nothing ->
                    ( [], [], 1 )

        ( scoreboardModel, scoreboardCmd ) =
            Scoreboard.State.init persistedScoreboard

        ( diceModel, diceCmd ) =
            Dice.State.init persistedDice

        cmds =
            Cmd.batch
                [ Cmd.map ScoreboardMsg scoreboardCmd
                , Cmd.map DiceMsg diceCmd
                , Task.perform (\vp -> UpdateAspectRatio (vp.viewport.width / vp.viewport.height)) Browser.Dom.getViewport
                ]
    in
    ( { scoreboard = scoreboardModel
      , dice = diceModel
      , roll = roll
      , tutorialMode = gamesPlayed == 0
      , menuOpen = False
      , modalStack = []
      , aspectRatio = Nothing
      , gamesPlayed = gamesPlayed
      , highScore = highScore
      , undo = Nothing
      }
    , cmds
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ScoreboardMsg scoreboardMsg ->
            let
                ( scoreboardModel, scoreboardCmd ) =
                    Scoreboard.State.update scoreboardMsg model.scoreboard <| Dice.Model.faces model.dice
            in
            ( { model | scoreboard = scoreboardModel }, Cmd.map ScoreboardMsg scoreboardCmd )

        DiceMsg diceMsg ->
            let
                ( diceModel, diceCmd ) =
                    Dice.State.update diceMsg model.dice

                persist =
                    case diceMsg of
                        Dice.Msg.NewFace _ _ ->
                            not <| Dice.Model.anyRolling diceModel

                        Dice.Msg.ToggleLock _ ->
                            True

                        _ ->
                            False
            in
            if persist then
                ( { model | dice = diceModel }, Cmd.map DiceMsg diceCmd )
                    |> andThen update PersistState

            else
                ( { model | dice = diceModel }, Cmd.map DiceMsg diceCmd )

        Roll ->
            ( { model | roll = model.roll + 1, undo = Nothing }, Cmd.none )
                |> andThen update (DiceMsg Dice.Msg.Roll)

        Score scoreKey ->
            let
                ( newModel, newCmd ) =
                    ( { model
                        | roll = 1
                        , tutorialMode = model.tutorialMode && Scoreboard.Model.turn model.scoreboard < 2
                      }
                    , Cmd.none
                    )
                        |> andThen update (ScoreboardMsg (Scoreboard.Msg.Score scoreKey))
                        |> andThen update (DiceMsg Dice.Msg.Reset)
                        |> andThen update PersistState
                        |> andThen update TryPersistGame
            in
            if Scoreboard.Model.isComplete newModel.scoreboard then
                ( newModel, newCmd )

            else
                ( { newModel
                    | undo =
                        Just
                            { scoreboard = model.scoreboard
                            , dice = model.dice
                            , roll = model.roll
                            , lastScoreKey = scoreKey
                            }
                  }
                , newCmd
                )

        Undo ->
            case model.undo of
                Just u ->
                    ( { model
                        | scoreboard = u.scoreboard
                        , dice = u.dice
                        , roll = u.roll
                        , undo = Nothing
                      }
                    , Cmd.none
                    )
                        |> andThen update PersistState

                Nothing ->
                    ( model, Cmd.none )

        NewGame ->
            ( { model
                | scoreboard = Scoreboard.Model.defaultModel
                , dice = Dice.Model.defaultModel
                , roll = 1
                , menuOpen = False
                , undo = Nothing
              }
            , Cmd.none
            )
                |> andThen update PersistState

        ToggleMenu ->
            ( { model | menuOpen = not model.menuOpen }, Cmd.none )

        ShowHelp helpKey ->
            ( { model | modalStack = View.Help.help helpKey :: model.modalStack }, Cmd.none )

        CloseModal ->
            ( { model | modalStack = List.drop 1 model.modalStack }, Cmd.none )

        UpdateAspectRatio aspectRatio ->
            ( { model | aspectRatio = Just aspectRatio }, Cmd.none )

        PersistState ->
            ( model
            , Ports.persistGameState
                { scoreboard = Dict.toList model.scoreboard
                , roll = model.roll
                , dice = Array.toList model.dice
                , tutorialMode = model.tutorialMode
                }
            )

        TryPersistGame ->
            ( model
            , if Scoreboard.Model.isComplete model.scoreboard then
                Task.perform (PersistGame model.scoreboard) Time.now

              else
                Cmd.none
            )

        PersistGame scoreboard time ->
            ( model
            , Ports.persistCompletedGame
                { v = 1
                , t = Time.posixToMillis time
                , g = Scoreboard.Model.grandTotal scoreboard
                , s = Dict.toList scoreboard
                }
            )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map DiceMsg (Dice.State.subscriptions model.dice)
        , Browser.Events.onResize (\w h -> UpdateAspectRatio (toFloat w / toFloat h))
        ]
