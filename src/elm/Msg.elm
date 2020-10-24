module Msg exposing (Msg(..))

import Dice.Msg
import Help.Model
import ImportExport.Msg
import Scoreboard.Model
import Scoreboard.Msg
import Stats.Msg
import Time


type Msg
    = ScoreboardMsg Scoreboard.Msg.Msg
    | DiceMsg Dice.Msg.Msg
    | StatsMsg Stats.Msg.Msg
    | ImportExportMsg ImportExport.Msg.Msg
    | Roll
    | Score Scoreboard.Model.ScoreKey
    | Undo
    | NewGame
    | ToggleMenu
    | ShowHelp Help.Model.HelpKey
    | ShowStats
    | ShowCredits
    | ShowImportExport
    | CloseModal
    | UpdateAspectRatio Float
    | PersistState
    | TryPersistGame
    | PersistGame Scoreboard.Model.Model Time.Posix
    | NoOp
