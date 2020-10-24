module State exposing (init, subscriptions, update)

import Array
import Browser.Dom
import Browser.Events
import Dice.Model
import Dice.Msg
import Dice.State
import Dict
import ImportExport.Msg
import ImportExport.State
import Model exposing (Model)
import ModelWrapper exposing (ModelWrapper)
import Msg exposing (Msg(..))
import Ports
import Scoreboard.Model
import Scoreboard.Msg
import Scoreboard.State
import Scoreboard.Summary
import Stats.Msg
import Stats.State
import Task
import Time
import Update.Extra exposing (andThen)
import View.Modals.Credits
import View.Modals.Help
import View.Modals.ImportExport
import View.Modals.Stats


init : Maybe Ports.Flags -> ( ModelWrapper, Cmd Msg )
init flags =
    let
        ( gameStateModel, history ) =
            case flags of
                Just f ->
                    ( f.gameState, Maybe.withDefault [] f.history )

                Nothing ->
                    ( Nothing, [] )

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

        ( statsModel, statsCmd ) =
            Stats.State.init history

        ( importExportModel, importExportCmd ) =
            ImportExport.State.init

        cmds =
            Cmd.batch
                [ Cmd.map ScoreboardMsg scoreboardCmd
                , Cmd.map DiceMsg diceCmd
                , Cmd.map StatsMsg statsCmd
                , Cmd.map ImportExportMsg importExportCmd
                , Task.perform (\vp -> UpdateAspectRatio (vp.viewport.width / vp.viewport.height)) Browser.Dom.getViewport
                ]
    in
    ( { model =
            { scoreboard = scoreboardModel
            , dice = diceModel
            , stats = statsModel
            , importExport = importExportModel
            , roll = roll
            , tutorialMode = statsModel.gamesPlayed == 0
            , menuOpen = False
            , aspectRatio = Nothing
            , undo = Nothing
            }
      , modalStack = []
      }
    , cmds
    )


update : Msg -> ModelWrapper -> ( ModelWrapper, Cmd Msg )
update msg modelWrapper =
    let
        model =
            modelWrapper.model

        updateModel : Model -> ModelWrapper
        updateModel newModel =
            { modelWrapper | model = newModel }
    in
    case msg of
        ScoreboardMsg scoreboardMsg ->
            let
                ( scoreboardModel, scoreboardCmd ) =
                    Scoreboard.State.update scoreboardMsg model.scoreboard <| Dice.Model.faces model.dice
            in
            ( updateModel { model | scoreboard = scoreboardModel }, Cmd.map ScoreboardMsg scoreboardCmd )

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
                ( updateModel { model | dice = diceModel }, Cmd.map DiceMsg diceCmd )
                    |> andThen update PersistState

            else
                ( updateModel { model | dice = diceModel }, Cmd.map DiceMsg diceCmd )

        StatsMsg statsMsg ->
            let
                ( statsModel, statsCmd ) =
                    Stats.State.update statsMsg model.stats
            in
            ( updateModel { model | stats = statsModel }, Cmd.map StatsMsg statsCmd )

        ImportExportMsg importExportMsg ->
            let
                ( importExportModel, importExportCmd ) =
                    ImportExport.State.update importExportMsg model.importExport
            in
            case importExportMsg of
                ImportExport.Msg.ImportHistorySuccess history ->
                    ( updateModel { model | importExport = importExportModel }, Cmd.map ImportExportMsg importExportCmd )
                        |> andThen update (StatsMsg (Stats.Msg.Init history))

                _ ->
                    ( updateModel { model | importExport = importExportModel }, Cmd.map ImportExportMsg importExportCmd )

        Roll ->
            ( updateModel { model | roll = model.roll + 1, undo = Nothing }, Cmd.none )
                |> andThen update (DiceMsg Dice.Msg.Roll)

        Score scoreKey ->
            let
                ( newModelWrapper, newCmd ) =
                    ( updateModel
                        { model
                            | roll = 1
                            , tutorialMode = model.tutorialMode && Scoreboard.Model.turn model.scoreboard < 2
                        }
                    , Cmd.none
                    )
                        |> andThen update (ScoreboardMsg (Scoreboard.Msg.Score scoreKey))
                        |> andThen update (DiceMsg Dice.Msg.Reset)
                        |> andThen update PersistState
                        |> andThen update TryPersistGame

                newModel =
                    newModelWrapper.model
            in
            if Scoreboard.Model.isComplete newModel.scoreboard then
                ( newModelWrapper, newCmd )
                    |> andThen update (StatsMsg (Stats.Msg.Update newModelWrapper.model.scoreboard))

            else
                ( updateModel
                    { newModel
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
                    ( updateModel
                        { model
                            | scoreboard = u.scoreboard
                            , dice = u.dice
                            , roll = u.roll
                            , undo = Nothing
                        }
                    , Cmd.none
                    )
                        |> andThen update PersistState

                Nothing ->
                    ( modelWrapper, Cmd.none )

        NewGame ->
            ( updateModel
                { model
                    | roll = 1
                    , menuOpen = False
                    , undo = Nothing
                }
            , Cmd.none
            )
                |> andThen update (ScoreboardMsg Scoreboard.Msg.Reset)
                |> andThen update (DiceMsg Dice.Msg.Reset)
                |> andThen update PersistState

        ToggleMenu ->
            ( updateModel { model | menuOpen = not model.menuOpen }, Cmd.none )

        ShowHelp helpKey ->
            ( { modelWrapper
                | modalStack = { modal = View.Modals.Help.help helpKey, onClose = NoOp } :: modelWrapper.modalStack
              }
            , Cmd.none
            )

        ShowStats ->
            ( { modelWrapper
                | modalStack = { modal = View.Modals.Stats.stats, onClose = NoOp } :: modelWrapper.modalStack
              }
            , Cmd.none
            )

        ShowCredits ->
            ( { modelWrapper
                | modalStack = { modal = View.Modals.Credits.credits, onClose = NoOp } :: modelWrapper.modalStack
              }
            , Cmd.none
            )

        ShowImportExport ->
            ( { modelWrapper
                | modalStack =
                    { modal = View.Modals.ImportExport.importExport, onClose = ImportExportMsg ImportExport.Msg.Clear }
                        :: modelWrapper.modalStack
              }
            , Cmd.none
            )

        CloseModal ->
            let
                topModal =
                    List.head modelWrapper.modalStack

                onClose =
                    case topModal of
                        Just modal ->
                            modal.onClose

                        Nothing ->
                            NoOp

                remainingStack =
                    Maybe.withDefault [] (List.tail modelWrapper.modalStack)
            in
            ( { modelWrapper
                | modalStack = remainingStack
                , model = { model | menuOpen = False }
              }
            , Cmd.none
            )
                |> andThen update onClose

        UpdateAspectRatio aspectRatio ->
            ( updateModel { model | aspectRatio = Just aspectRatio }, Cmd.none )

        PersistState ->
            ( modelWrapper
            , Ports.persistGameState
                { scoreboard = Dict.toList model.scoreboard
                , roll = model.roll
                , dice = Array.toList model.dice
                , tutorialMode = model.tutorialMode
                }
            )

        TryPersistGame ->
            ( modelWrapper
            , if Scoreboard.Model.isComplete model.scoreboard then
                Task.perform (PersistGame model.scoreboard) Time.now

              else
                Cmd.none
            )

        PersistGame scoreboard time ->
            ( modelWrapper
            , Ports.persistCompletedGame
                { v = 1
                , t = Time.posixToMillis time
                , g = Scoreboard.Summary.grandTotal scoreboard
                , s = Dict.toList scoreboard
                }
            )

        NoOp ->
            ( modelWrapper, Cmd.none )


subscriptions : ModelWrapper -> Sub Msg
subscriptions modelWrapper =
    Sub.batch
        [ Sub.map DiceMsg (Dice.State.subscriptions modelWrapper.model.dice)
        , Sub.map ImportExportMsg ImportExport.State.subscriptions
        , Browser.Events.onResize (\w h -> UpdateAspectRatio (toFloat w / toFloat h))
        ]
