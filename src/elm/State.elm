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
import ModalStack.Model
import ModalStack.State
import Model exposing (ModalStack(..), Model)
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


init : Maybe Ports.Flags -> ( Model, Cmd Msg )
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

        ( modalStackModel, modalStackCmd ) =
            ModalStack.State.init

        ( statsModel, statsCmd ) =
            Stats.State.init history

        ( importExportModel, importExportCmd ) =
            ImportExport.State.init

        cmds =
            Cmd.batch
                [ Cmd.map ScoreboardMsg scoreboardCmd
                , Cmd.map DiceMsg diceCmd
                , Cmd.map ModalStackMsg modalStackCmd
                , Cmd.map StatsMsg statsCmd
                , Cmd.map ImportExportMsg importExportCmd
                , Task.perform (\vp -> UpdateAspectRatio (vp.viewport.width / vp.viewport.height)) Browser.Dom.getViewport
                , Task.perform InitTimeZone Time.here
                ]
    in
    ( { scoreboard = scoreboardModel
      , dice = diceModel
      , stats = statsModel
      , modalStack = ModalStack modalStackModel
      , importExport = importExportModel
      , roll = roll
      , tutorialMode = statsModel.gamesPlayed == 0
      , menuOpen = False
      , aspectRatio = Nothing
      , undo = Nothing
      , timeZone = Time.utc
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

        ModalStackMsg modalStackMsg ->
            let
                extractModel : ModalStack -> ModalStack.Model.Model Model Msg
                extractModel (ModalStack modalStack) =
                    modalStack

                ( modalStackModel, modalStackCmd, modalStackCb ) =
                    ModalStack.State.update modalStackMsg <| extractModel model.modalStack
            in
            ( { model | modalStack = ModalStack modalStackModel }, Cmd.map ModalStackMsg modalStackCmd )
                |> andThen update modalStackCb

        StatsMsg statsMsg ->
            let
                ( statsModel, statsCmd ) =
                    Stats.State.update statsMsg model.stats
            in
            ( { model | stats = statsModel }, Cmd.map StatsMsg statsCmd )

        ImportExportMsg importExportMsg ->
            let
                ( importExportModel, importExportCmd ) =
                    ImportExport.State.update importExportMsg model.importExport
            in
            case importExportMsg of
                ImportExport.Msg.ImportHistorySuccess history ->
                    ( { model | importExport = importExportModel }, Cmd.map ImportExportMsg importExportCmd )
                        |> andThen update (StatsMsg (Stats.Msg.Init history))

                _ ->
                    ( { model | importExport = importExportModel }, Cmd.map ImportExportMsg importExportCmd )

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
            ( { model | menuOpen = not model.menuOpen }, Cmd.none )

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
            let
                game : Ports.GameModel
                game =
                    { v = 1
                    , t = Time.posixToMillis time
                    , g = Scoreboard.Summary.grandTotal scoreboard
                    , s = Dict.toList scoreboard
                    }

                ( newModel, newCmd ) =
                    update (StatsMsg (Stats.Msg.Update game)) model
            in
            ( newModel
            , Cmd.batch
                [ newCmd
                , Ports.persistCompletedGame game
                ]
            )

        InitTimeZone timeZone ->
            ( { model | timeZone = timeZone }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map DiceMsg (Dice.State.subscriptions model.dice)
        , Sub.map ImportExportMsg ImportExport.State.subscriptions
        , Browser.Events.onResize (\w h -> UpdateAspectRatio (toFloat w / toFloat h))
        ]
