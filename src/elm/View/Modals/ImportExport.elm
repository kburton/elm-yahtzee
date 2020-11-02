module View.Modals.ImportExport exposing (importExport)

import Html exposing (Html, button, div, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import ModalStack.Model as Modal
import Model exposing (Model)
import Msg
import Persistence.Model
import Persistence.Msg


importExport : Model -> Modal.Modal Msg.Msg
importExport model =
    { title = "Import / Export"
    , body = Modal.Sections [ exportSection, importSection model.persistence.importStage ]
    }


exportSection : Modal.Section Msg.Msg
exportSection =
    { header = "Export Game History"
    , content =
        div []
            [ p [] [ text "Click the button below to download your current game history and stats so they can be imported on another device." ]
            , p [] [ button [ onClick (Msg.PersistenceMsg Persistence.Msg.ExportHistory) ] [ text "Export History" ] ]
            ]
    }


importSection : Persistence.Model.ImportStage -> Modal.Section Msg.Msg
importSection result =
    { header = "Import Game History"
    , content =
        div []
            ([ p [] [ text "Upload an exported file to restore your history. Note that this will delete any existing history on this device." ]
             , p [] [ button [ onClick (Msg.PersistenceMsg Persistence.Msg.UploadFile) ] [ text "Import History" ] ]
             ]
                ++ importResult result
            )
    }


importResult : Persistence.Model.ImportStage -> List (Html Msg.Msg)
importResult importStage =
    case importStage of
        Persistence.Model.ImportStageChecked { result } ->
            case result of
                Ok history ->
                    [ p [] [ text <| "Import " ++ String.fromInt (List.length history) ++ " historical games?" ]
                    , p []
                        [ button
                            [ onClick (Msg.PersistenceMsg Persistence.Msg.ImportHistory), class "import-export__import-confirm" ]
                            [ text "Complete Import" ]
                        , button
                            [ onClick (Msg.PersistenceMsg Persistence.Msg.CancelImport) ]
                            [ text "Cancel Import" ]
                        ]
                    ]

                Err error ->
                    [ p [ class "import-export__import-result--error" ] [ text <| "Import failed: " ++ error ] ]

        Persistence.Model.ImportStageImported (Ok ()) ->
            [ p [ class "import-export__import-result--success" ] [ text "Import completed successfully!" ] ]

        Persistence.Model.ImportStageImported (Err error) ->
            [ p [ class "import-export__import-result--error" ] [ text <| "Import failed: " ++ error ] ]

        Persistence.Model.ImportStageUploaded _ ->
            []

        Persistence.Model.ImportStageNone ->
            []
