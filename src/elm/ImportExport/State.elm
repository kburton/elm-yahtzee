module ImportExport.State exposing (init, subscriptions, update)

import File
import File.Download
import File.Select
import ImportExport.Model exposing (ImportStage(..), Model, defaultModel)
import ImportExport.Msg exposing (Msg(..))
import Ports
import Task


init : ( Model, Cmd Msg )
init =
    ( defaultModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ExportHistory ->
            ( model
            , Ports.exportHistory ()
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
            ( { model | importStage = ImportStageUploaded content }, Ports.importHistoryCheck content )

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
                            ( model, Ports.importHistory rec.uploadedContent )

                        _ ->
                            ( defaultModel, Cmd.none )

                _ ->
                    ( defaultModel, Cmd.none )

        ImportHistorySuccess _ ->
            ( { model | importStage = ImportStageImported (Ok ()) }, Cmd.none )

        ImportHistoryFailure error ->
            ( { model | importStage = ImportStageImported (Err error) }, Cmd.none )

        Clear ->
            ( defaultModel, Cmd.none )


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Ports.exportHistoryResponse DownloadExportedHistory
        , Ports.importHistoryCheckSuccess ImportHistoryCheckSuccess
        , Ports.importHistoryCheckFailure ImportHistoryCheckFailure
        , Ports.importHistorySuccess ImportHistorySuccess
        , Ports.importHistoryFailure ImportHistoryFailure
        ]
