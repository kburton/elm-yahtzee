module View.Modals.ImportExport exposing (importExport)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import ImportExport.Msg exposing (Msg(..))
import Modal.Model as Modal
import Model exposing (Model)
import Msg exposing (Msg)


importExport : Model -> Modal.Model
importExport model =
    { title = "Import / Export"
    , sections = [ exportSection, importSection model.importExport.importResult ]
    }


exportSection : Modal.Section
exportSection =
    { header = "Export Game History"
    , content =
        div []
            [ text "Click the button below to download your current game history and stats so they can be imported on another device."
            , button [ onClick (Msg.ImportExportMsg ExportHistory) ] [ text "Export History" ]
            ]
    }


importSection : Maybe (Result String ()) -> Modal.Section
importSection result =
    { header = "Import Game History"
    , content =
        div []
            ([ text "Upload an exported file to restore your history. Note that this will delete any existing history on this device."
             , button [ onClick (Msg.ImportExportMsg ImportHistory) ] [ text "Import History" ]
             ]
                ++ importResult result
            )
    }


importResult : Maybe (Result String ()) -> List (Html msg)
importResult result =
    case result of
        Just (Ok ()) ->
            [ div [] [ text "Import completed successfully" ] ]

        Just (Err error) ->
            [ div [] [ text <| "Import failed: " ++ error ] ]

        Nothing ->
            []
