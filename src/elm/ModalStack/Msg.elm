module ModalStack.Msg exposing (Msg(..))

import Help.Model
import Stats.Model


type Msg
    = ShowMenu
    | ShowHelp Help.Model.HelpKey
    | ShowStats
    | ShowCredits
    | ShowImportExport
    | ShowCompletedGame Stats.Model.Game
    | Close
    | Clear
