module State exposing (init, subscriptions, update)

import Browser.Dom
import Browser.Events
import Browser.Navigation
import Dice.Model
import Dice.Msg
import Dice.State
import ModalStack.Model
import ModalStack.Msg
import ModalStack.State
import Model exposing (ModalStack(..), Model, defaultGameState, extractModalStack)
import Msg exposing (Msg(..))
import Persistence.Flags
import Persistence.Msg
import Persistence.Serialization
import Persistence.State
import Router.Model
import Router.Msg
import Router.State
import Scoreboard.Model
import Scoreboard.Msg
import Scoreboard.State
import Stats.Model
import Stats.Msg
import Stats.State
import Task
import Time
import Update.Extra exposing (andThen, filter)
import Url exposing (Url)


init : Maybe Persistence.Flags.Flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        persistenceInitResult =
            Persistence.State.init flags

        gameState =
            Maybe.withDefault defaultGameState persistenceInitResult.gameState

        ( scoreboardModel, scoreboardCmd ) =
            Scoreboard.State.init gameState.scoreboard

        ( diceModel, diceCmd ) =
            Dice.State.init gameState.dice

        ( modalStackModel, modalStackCmd ) =
            ModalStack.State.init

        ( statsModel, statsCmd ) =
            Stats.State.init persistenceInitResult.history

        ( routerModel, routerCmd ) =
            Router.State.init url navKey

        cmds =
            Cmd.batch
                [ Cmd.map ScoreboardMsg scoreboardCmd
                , Cmd.map DiceMsg diceCmd
                , Cmd.map ModalStackMsg modalStackCmd
                , Cmd.map StatsMsg statsCmd
                , Cmd.map PersistenceMsg persistenceInitResult.cmd
                , Cmd.map RouterMsg routerCmd
                , Task.perform (\vp -> UpdateAspectRatio (vp.viewport.width / vp.viewport.height)) Browser.Dom.getViewport
                , Task.perform InitTimeZone Time.here
                ]
    in
    ( { game =
            { scoreboard = scoreboardModel
            , dice = diceModel
            , roll = gameState.roll
            }
      , stats = statsModel
      , modalStack = ModalStack modalStackModel
      , persistence = persistenceInitResult.model
      , router = routerModel
      , tutorialMode = statsModel.gamesPlayed == 0
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
                    Scoreboard.State.update scoreboardMsg model.game.scoreboard <| Dice.Model.faces model.game.dice

                game =
                    { scoreboard = scoreboardModel, dice = Dice.Model.defaultModel, roll = 1 }
            in
            case scoreboardMsg of
                Scoreboard.Msg.Score scoreKey ->
                    ( if Scoreboard.Model.isComplete scoreboardModel then
                        { model | game = game }

                      else
                        { model
                            | game = game
                            , tutorialMode = model.tutorialMode && Scoreboard.Model.turn model.game.scoreboard < 2
                            , undo =
                                Just
                                    { scoreboard = model.game.scoreboard
                                    , dice = model.game.dice
                                    , roll = model.game.roll
                                    , lastScoreKey = scoreKey
                                    }
                        }
                    , Cmd.map ScoreboardMsg scoreboardCmd
                    )
                        |> andThen update (PersistenceMsg Persistence.Msg.PersistState)
                        |> andThen update (PersistenceMsg Persistence.Msg.TryPersistGame)

        DiceMsg diceMsg ->
            let
                ( diceModel, diceCmd ) =
                    Dice.State.update diceMsg model.game.dice

                persist =
                    case diceMsg of
                        Dice.Msg.NewFace _ _ ->
                            not <| Dice.Model.anyRolling diceModel

                        Dice.Msg.ToggleLock _ ->
                            True

                        _ ->
                            False

                game =
                    { scoreboard = model.game.scoreboard, dice = diceModel, roll = model.game.roll }
            in
            if persist then
                ( { model | game = game }, Cmd.map DiceMsg diceCmd )
                    |> andThen update (PersistenceMsg Persistence.Msg.PersistState)

            else
                ( { model | game = game }, Cmd.map DiceMsg diceCmd )

        ModalStackMsg modalStackMsg ->
            let
                ( modalStackModel, modalStackCmd, modalStackCb ) =
                    ModalStack.State.update modalStackMsg <| extractModalStack model.modalStack
            in
            ( { model | modalStack = ModalStack modalStackModel }
            , Cmd.map ModalStackMsg modalStackCmd
            )
                |> andThen update modalStackCb
                |> andThen update (RouterMsg <| Router.Msg.UpdateFragment <| ModalStack.Model.modalCount modalStackModel)

        StatsMsg statsMsg ->
            let
                ( statsModel, statsCmd ) =
                    Stats.State.update statsMsg model.stats
            in
            ( { model | stats = statsModel }, Cmd.map StatsMsg statsCmd )

        PersistenceMsg persistenceMsg ->
            let
                ( persistenceModel, persistenceCmd ) =
                    Persistence.State.update persistenceMsg model.persistence model.game
            in
            case persistenceMsg of
                Persistence.Msg.PersistGame scoreboard time ->
                    ( { model | persistence = persistenceModel }, Cmd.map PersistenceMsg persistenceCmd )
                        |> andThen update
                            (StatsMsg <| Stats.Msg.Update <| Stats.Model.makeGame scoreboard time)

                Persistence.Msg.ImportHistorySuccess history ->
                    ( { model | persistence = persistenceModel }, Cmd.map PersistenceMsg persistenceCmd )
                        |> andThen update
                            (StatsMsg <| Stats.Msg.Init <| Persistence.Serialization.deserializeGameHistory <| Just history)

                _ ->
                    ( { model | persistence = persistenceModel }, Cmd.map PersistenceMsg persistenceCmd )

        RouterMsg routerMsg ->
            let
                ( routerModel, routerCmd ) =
                    Router.State.update routerMsg model.router

                routerModalCount =
                    Router.Model.modalCount routerModel

                modalCount =
                    ModalStack.Model.modalCount <| extractModalStack model.modalStack

                isUrlChangedMsg =
                    case routerMsg of
                        Router.Msg.UrlChanged _ ->
                            True

                        _ ->
                            False
            in
            ( { model | router = routerModel }, Cmd.map RouterMsg routerCmd )
                |> filter (isUrlChangedMsg && routerModalCount < modalCount)
                    (andThen update <| ModalStackMsg ModalStack.Msg.Close)

        Roll ->
            ( { model
                | game =
                    { scoreboard = model.game.scoreboard
                    , dice = model.game.dice
                    , roll = model.game.roll + 1
                    }
                , undo = Nothing
              }
            , Cmd.none
            )
                |> andThen update (DiceMsg Dice.Msg.Roll)

        Undo ->
            case model.undo of
                Just u ->
                    ( { model
                        | game =
                            { scoreboard = u.scoreboard
                            , dice = u.dice
                            , roll = u.roll
                            }
                      }
                    , Cmd.none
                    )
                        |> andThen update (PersistenceMsg Persistence.Msg.PersistState)

                Nothing ->
                    ( model, Cmd.none )

        NewGame ->
            ( { model
                | game = defaultGameState
                , undo = Nothing
              }
            , Cmd.none
            )
                |> andThen update (ModalStackMsg ModalStack.Msg.Clear)
                |> andThen update (PersistenceMsg Persistence.Msg.PersistState)

        UpdateAspectRatio aspectRatio ->
            ( { model | aspectRatio = Just aspectRatio }, Cmd.none )

        InitTimeZone timeZone ->
            ( { model | timeZone = timeZone }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map DiceMsg (Dice.State.subscriptions model.game.dice)
        , Sub.map PersistenceMsg Persistence.State.subscriptions
        , Browser.Events.onResize (\w h -> UpdateAspectRatio (toFloat w / toFloat h))
        ]
