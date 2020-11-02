module ModalStack.Msg exposing (Msg(..))

import Help.Model
import Stats.Model


type Msg
    = ShowHelp Help.Model.HelpKey
    | ShowStats
    | ShowCredits
    | ShowImportExport
    | ShowCompletedGame Stats.Model.Game
    | Close
