module ImportExport.Msg exposing (Msg(..))

import File
import Ports


type Msg
    = ExportHistory
    | DownloadExportedHistory String
    | ImportHistory
    | ProcessImportedHistory File.File
    | PersistImportedHistory String
    | ImportHistoryCheck Ports.HistoryModel
    | ImportHistorySuccess Ports.HistoryModel
    | ImportHistoryFailure String
