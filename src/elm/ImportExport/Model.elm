module ImportExport.Model exposing (ImportStage(..), Model, defaultModel)

import Ports


type ImportStage
    = ImportStageNone
    | ImportStageUploaded String
    | ImportStageChecked { uploadedContent : String, result : Result String Ports.HistoryModel }
    | ImportStageImported (Result String ())


type alias Model =
    { importStage : ImportStage
    }


defaultModel : Model
defaultModel =
    { importStage = ImportStageNone
    }
