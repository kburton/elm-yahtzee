module ModalStack.State exposing (init, update)

import ImportExport.Msg as ImportExportMsg
import ModalStack.Model exposing (Model)
import ModalStack.Msg exposing (Msg(..))
import Model as RootModel
import Msg as RootMsg
import View.Modals.CompletedGame
import View.Modals.Credits
import View.Modals.Help
import View.Modals.ImportExport
import View.Modals.Stats


init : ( Model RootModel.Model RootMsg.Msg, Cmd Msg )
init =
    ( [], Cmd.none )


update : Msg -> Model RootModel.Model RootMsg.Msg -> ( Model RootModel.Model RootMsg.Msg, Cmd Msg, RootMsg.Msg )
update msg model =
    case msg of
        ShowHelp helpKey ->
            ( { modal = View.Modals.Help.help helpKey, onClose = RootMsg.NoOp } :: model
            , Cmd.none
            , RootMsg.NoOp
            )

        ShowStats ->
            ( { modal = View.Modals.Stats.stats, onClose = RootMsg.NoOp } :: model
            , Cmd.none
            , RootMsg.NoOp
            )

        ShowCredits ->
            ( { modal = View.Modals.Credits.credits, onClose = RootMsg.NoOp } :: model
            , Cmd.none
            , RootMsg.NoOp
            )

        ShowImportExport ->
            ( { modal = View.Modals.ImportExport.importExport, onClose = RootMsg.ImportExportMsg ImportExportMsg.Clear } :: model
            , Cmd.none
            , RootMsg.NoOp
            )

        ShowCompletedGame game ->
            ( { modal = View.Modals.CompletedGame.completedGame game, onClose = RootMsg.NoOp } :: model
            , Cmd.none
            , RootMsg.NoOp
            )

        Close ->
            let
                topModal =
                    List.head model

                onClose =
                    case topModal of
                        Just modal ->
                            modal.onClose

                        Nothing ->
                            RootMsg.NoOp

                remainingModals =
                    Maybe.withDefault [] <| List.tail model
            in
            ( remainingModals, Cmd.none, onClose )
