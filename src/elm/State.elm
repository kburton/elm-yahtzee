module State exposing (init, subscriptions, update)

import Browser.Dom
import Browser.Events
import Dice.Model
import Dice.Msg
import Dice.State
import ModalStack.Model
import ModalStack.State
import Model exposing (ModalStack(..), Model, defaultGameState)
import Msg exposing (Msg(..))
import Persistence.Flags
import Persistence.Msg
import Persistence.Serialization
import Persistence.State
import Scoreboard.Model
import Scoreboard.Msg
import Scoreboard.State
import Stats.Model
import Stats.Msg
import Stats.State
import Task
import Time
import Update.Extra exposing (andThen)


init : Maybe Persistence.Flags.Flags -> ( Model, Cmd Msg )
init flags =
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

        cmds =
            Cmd.batch
                [ Cmd.map ScoreboardMsg scoreboardCmd
                , Cmd.map DiceMsg diceCmd
                , Cmd.map ModalStackMsg modalStackCmd
                , Cmd.map StatsMsg statsCmd
                , Cmd.map PersistenceMsg persistenceInitResult.cmd
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
                    Scoreboard.State.update scoreboardMsg model.game.scoreboard <| Dice.Model.faces model.game.dice

                game =
                    { scoreboard = scoreboardModel, dice = model.game.dice, roll = model.game.roll }
            in
            ( { model | game = game }, Cmd.map ScoreboardMsg scoreboardCmd )

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

        PersistenceMsg persistenceMsg ->
            let
                ( persistenceModel, persistenceCmd ) =
                    Persistence.State.update persistenceMsg model.persistence model.game
            in
            case persistenceMsg of
                Persistence.Msg.PersistGame scoreboard time ->
                    ( { model | persistence = persistenceModel }, Cmd.map PersistenceMsg persistenceCmd )
                        |> andThen update
                            (StatsMsg <|
                                Stats.Msg.Update <|
                                    Stats.Model.makeGame scoreboard time
                            )

                Persistence.Msg.ImportHistorySuccess history ->
                    ( { model | persistence = persistenceModel }, Cmd.map PersistenceMsg persistenceCmd )
                        |> andThen update
                            (StatsMsg <|
                                Stats.Msg.Init <|
                                    Persistence.Serialization.deserializeGameHistory <|
                                        Just history
                            )

                _ ->
                    ( { model | persistence = persistenceModel }, Cmd.map PersistenceMsg persistenceCmd )

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

        Score scoreKey ->
            let
                ( newModel, newCmd ) =
                    ( { model
                        | game = { scoreboard = model.game.scoreboard, dice = model.game.dice, roll = 1 }
                        , tutorialMode = model.tutorialMode && Scoreboard.Model.turn model.game.scoreboard < 2
                      }
                    , Cmd.none
                    )
                        |> andThen update (ScoreboardMsg (Scoreboard.Msg.Score scoreKey))
                        |> andThen update (DiceMsg Dice.Msg.Reset)
                        |> andThen update (PersistenceMsg Persistence.Msg.PersistState)
                        |> andThen update (PersistenceMsg Persistence.Msg.TryPersistGame)
            in
            if Scoreboard.Model.isComplete newModel.game.scoreboard then
                ( newModel, newCmd )

            else
                ( { newModel
                    | undo =
                        Just
                            { scoreboard = model.game.scoreboard
                            , dice = model.game.dice
                            , roll = model.game.roll
                            , lastScoreKey = scoreKey
                            }
                  }
                , newCmd
                )

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
                , menuOpen = False
                , undo = Nothing
              }
            , Cmd.none
            )
                |> andThen update (PersistenceMsg Persistence.Msg.PersistState)

        ToggleMenu ->
            ( { model | menuOpen = not model.menuOpen }, Cmd.none )

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
