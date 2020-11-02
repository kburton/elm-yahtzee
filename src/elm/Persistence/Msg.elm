module Persistence.Msg exposing (Msg(..))

import File
import Persistence.Model exposing (PersistedGameHistory)
import Scoreboard.Model
import Time


type Msg
    = PersistState
    | TryPersistGame
    | PersistGame Scoreboard.Model.Model Time.Posix
    | ExportHistory
    | DownloadExportedHistory String
    | UploadFile
    | ProcessUploadedFile File.File
    | ProcessUploadedFileContent String
    | ImportHistoryCheckSuccess PersistedGameHistory
    | ImportHistoryCheckFailure String
    | CancelImport
    | ImportHistory
    | ImportHistorySuccess PersistedGameHistory
    | ImportHistoryFailure String
    | ClearImport
