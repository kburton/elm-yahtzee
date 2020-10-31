module View.Modals.ImportExport exposing (importExport)

import Html exposing (Html, button, div, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import ImportExport.Model
import ImportExport.Msg
import ModalStack.Model as Modal
import Model exposing (Model)
import Msg


importExport : Model -> Modal.Modal Msg.Msg
importExport model =
    { title = "Import / Export"
    , body = Modal.Sections [ exportSection, importSection model.importExport.importStage ]
    }


exportSection : Modal.Section Msg.Msg
exportSection =
    { header = "Export Game History"
    , content =
        div []
            [ p [] [ text "Click the button below to download your current game history and stats so they can be imported on another device." ]
            , p [] [ button [ onClick (Msg.ImportExportMsg ImportExport.Msg.ExportHistory) ] [ text "Export History" ] ]
            ]
    }


importSection : ImportExport.Model.ImportStage -> Modal.Section Msg.Msg
importSection result =
    { header = "Import Game History"
    , content =
        div []
            ([ p [] [ text "Upload an exported file to restore your history. Note that this will delete any existing history on this device." ]
             , p [] [ button [ onClick (Msg.ImportExportMsg ImportExport.Msg.UploadFile) ] [ text "Import History" ] ]
             ]
                ++ importResult result
            )
    }


importResult : ImportExport.Model.ImportStage -> List (Html Msg.Msg)
importResult importStage =
    case importStage of
        ImportExport.Model.ImportStageChecked { result } ->
            case result of
                Ok history ->
                    [ p [] [ text <| "Import " ++ String.fromInt (List.length history) ++ " historical games?" ]
                    , p []
                        [ button
                            [ onClick (Msg.ImportExportMsg ImportExport.Msg.ImportHistory), class "import-export__import-confirm" ]
                            [ text "Complete Import" ]
                        , button
                            [ onClick (Msg.ImportExportMsg ImportExport.Msg.CancelImport) ]
                            [ text "Cancel Import" ]
                        ]
                    ]

                Err error ->
                    [ p [ class "import-export__import-result--error" ] [ text <| "Import failed: " ++ error ] ]

        ImportExport.Model.ImportStageImported (Ok ()) ->
            [ p [ class "import-export__import-result--success" ] [ text "Import completed successfully!" ] ]

        ImportExport.Model.ImportStageImported (Err error) ->
            [ p [ class "import-export__import-result--error" ] [ text <| "Import failed: " ++ error ] ]

        ImportExport.Model.ImportStageUploaded _ ->
            []

        ImportExport.Model.ImportStageNone ->
            []
