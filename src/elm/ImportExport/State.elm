module ImportExport.State exposing (init, subscriptions, update)

import File
import File.Download
import File.Select
import ImportExport.Model exposing (Model)
import ImportExport.Msg exposing (..)
import Ports
import Task


init : ( Model, Cmd Msg )
init =
    ( { importResult = Nothing }, Cmd.none )


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

        ImportHistory ->
            ( { model | importResult = Nothing }
            , File.Select.file [ "text/plain" ] ProcessImportedHistory
            )

        ProcessImportedHistory file ->
            ( model, Task.perform PersistImportedHistory (File.toString file) )

        PersistImportedHistory history ->
            ( model, Ports.importHistory history )

        ImportHistoryCheck history ->
            ( model, Cmd.none )

        ImportHistorySuccess history ->
            ( { model | importResult = Just (Ok ()) }, Cmd.none )

        ImportHistoryFailure error ->
            ( { model | importResult = Just (Err error) }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.exportHistoryResponse DownloadExportedHistory
        , Ports.importHistoryCheck ImportHistoryCheck
        , Ports.importHistorySuccess ImportHistorySuccess
        , Ports.importHistoryFailure ImportHistoryFailure
        ]
