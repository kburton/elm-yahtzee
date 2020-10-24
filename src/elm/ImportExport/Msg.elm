module ImportExport.Msg exposing (Msg(..))

import File
import Ports


type Msg
    = ExportHistory
    | DownloadExportedHistory String
    | UploadFile
    | ProcessUploadedFile File.File
    | ProcessUploadedFileContent String
    | ImportHistoryCheckSuccess Ports.HistoryModel
    | ImportHistoryCheckFailure String
    | CancelImport
    | ImportHistory
    | ImportHistorySuccess Ports.HistoryModel
    | ImportHistoryFailure String
    | Clear
