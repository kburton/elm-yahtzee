module ModalStack.Msg exposing (Msg(..))

import Help.Model
import Ports


type Msg
    = ShowHelp Help.Model.HelpKey
    | ShowStats
    | ShowCredits
    | ShowImportExport
    | ShowCompletedGame Ports.GameModel
    | Close
