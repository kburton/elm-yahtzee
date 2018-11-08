module State exposing (init, subscriptions, update)

import Browser.Dom
import Browser.Events
import Game.Scoreboard
import Game.State
import Game.Types
import Html
import Ports
import Task
import Types


init : Maybe Ports.Flags -> ( Types.Model, Cmd Types.Msg )
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

        ( gameModel, gameCmd ) =
            Game.State.init gameStateModel gamesPlayed

        cmds =
            Cmd.batch
                [ Cmd.map Types.GameMsg gameCmd
                , Task.perform (\vp -> Types.UpdateAspectRatio (vp.viewport.width / vp.viewport.height)) Browser.Dom.getViewport
                ]
    in
    ( { game = gameModel
      , menuOpen = False
      , modal = Nothing
      , aspectRatio = Nothing
      , gamesPlayed = gamesPlayed
      , highScore = highScore
      }
    , cmds
    )


update : Types.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg model =
    case msg of
        Types.GameMsg gameMsg ->
            case gameMsg of
                Game.Types.ShowHelp header sections ->
                    ( { model | modal = Just ( header, List.map (\( h, s ) -> ( h, Html.map Types.GameMsg s )) sections ) }, Cmd.none )

                _ ->
                    let
                        ( gameModel, gameCmd ) =
                            Game.State.update gameMsg model.game

                        menuOpen =
                            gameMsg /= Game.Types.NewGame && model.menuOpen

                        ( gamesPlayed, highScore ) =
                            case gameMsg of
                                Game.Types.Persist m _ ->
                                    ( model.gamesPlayed + 1, max (Game.Scoreboard.grandTotal m.scoreboard) model.highScore )

                                _ ->
                                    ( model.gamesPlayed, model.highScore )
                    in
                    ( { model | game = gameModel, menuOpen = menuOpen, gamesPlayed = gamesPlayed, highScore = highScore }
                    , Cmd.map Types.GameMsg gameCmd
                    )

        Types.ToggleMenu ->
            ( { model | menuOpen = not model.menuOpen }, Cmd.none )

        Types.OpenModal payload ->
            ( { model | modal = Just payload }, Cmd.none )

        Types.CloseModal ->
            ( { model | modal = Nothing }, Cmd.none )

        Types.UpdateAspectRatio aspectRatio ->
            ( { model | aspectRatio = Just aspectRatio }, Cmd.none )

        Types.NoOp ->
            ( model, Cmd.none )


subscriptions : Types.Model -> Sub Types.Msg
subscriptions model =
    Sub.batch
        [ Sub.map Types.GameMsg (Game.State.subscriptions model.game)
        , Browser.Events.onResize (\w h -> Types.UpdateAspectRatio (toFloat w / toFloat h))
        ]
