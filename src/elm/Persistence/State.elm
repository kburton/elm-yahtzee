module Persistence.State exposing (init, subscriptions, update)

import File
import File.Download
import File.Select
import Model exposing (GameState)
import Persistence.Flags exposing (Flags)
import Persistence.Model exposing (GameHistory, ImportStage(..), Model, defaultModel)
import Persistence.Msg exposing (Msg(..))
import Persistence.Ports
import Persistence.Serialization exposing (deserializeGameHistory, deserializeGameState, serializeGame, serializeGameState)
import Scoreboard.Model
import Stats.Model
import Task
import Time


init : Maybe Flags -> { model : Model, cmd : Cmd Msg, gameState : Maybe GameState, history : GameHistory }
init maybeFlags =
    let
        flags =
            Maybe.withDefault { gameState = Nothing, history = Nothing } maybeFlags
    in
    { model = defaultModel
    , cmd = Cmd.none
    , gameState = deserializeGameState flags.gameState
    , history = deserializeGameHistory flags.history
    }


update : Msg -> Model -> GameState -> ( Model, Cmd Msg )
update msg model gameState =
    case msg of
        PersistState ->
            ( model
            , Persistence.Ports.persistGameState <| serializeGameState gameState
            )

        TryPersistGame ->
            ( model
            , if Scoreboard.Model.isComplete gameState.scoreboard then
                Task.perform (PersistGame gameState.scoreboard) Time.now

              else
                Cmd.none
            )

        PersistGame scoreboard time ->
            ( model
            , Persistence.Ports.persistCompletedGame <| serializeGame <| Stats.Model.makeGame scoreboard time
            )

        ExportHistory ->
            ( model
            , Persistence.Ports.exportHistory ()
            )

        DownloadExportedHistory history ->
            ( model
            , File.Download.string "elm-yahtzee-export.txt" "text/plain" history
            )

        CancelImport ->
            ( defaultModel, Cmd.none )

        UploadFile ->
            ( defaultModel
            , File.Select.file [ "text/plain" ] ProcessUploadedFile
            )

        ProcessUploadedFile file ->
            ( model, Task.perform ProcessUploadedFileContent (File.toString file) )

        ProcessUploadedFileContent content ->
            ( { model | importStage = ImportStageUploaded content }, Persistence.Ports.importHistoryCheck content )

        ImportHistoryCheckSuccess history ->
            case model.importStage of
                ImportStageUploaded content ->
                    ( { model | importStage = ImportStageChecked { uploadedContent = content, result = Ok history } }, Cmd.none )

                _ ->
                    ( defaultModel, Cmd.none )

        ImportHistoryCheckFailure error ->
            case model.importStage of
                ImportStageUploaded content ->
                    ( { model | importStage = ImportStageChecked { uploadedContent = content, result = Err error } }, Cmd.none )

                _ ->
                    ( defaultModel, Cmd.none )

        ImportHistory ->
            case model.importStage of
                ImportStageChecked rec ->
                    case rec.result of
                        Ok _ ->
                            ( model, Persistence.Ports.importHistory rec.uploadedContent )

                        _ ->
                            ( defaultModel, Cmd.none )

                _ ->
                    ( defaultModel, Cmd.none )

        ImportHistorySuccess _ ->
            ( { model | importStage = ImportStageImported (Ok ()) }, Cmd.none )

        ImportHistoryFailure error ->
            ( { model | importStage = ImportStageImported (Err error) }, Cmd.none )

        ClearImport ->
            ( defaultModel, Cmd.none )


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Persistence.Ports.exportHistoryResponse DownloadExportedHistory
        , Persistence.Ports.importHistoryCheckSuccess ImportHistoryCheckSuccess
        , Persistence.Ports.importHistoryCheckFailure ImportHistoryCheckFailure
        , Persistence.Ports.importHistorySuccess ImportHistorySuccess
        , Persistence.Ports.importHistoryFailure ImportHistoryFailure
        ]
