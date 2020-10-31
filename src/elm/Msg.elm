module Msg exposing (Msg(..))

import Dice.Msg
import ImportExport.Msg
import ModalStack.Msg
import Scoreboard.Model
import Scoreboard.Msg
import Stats.Msg
import Time


type Msg
    = ScoreboardMsg Scoreboard.Msg.Msg
    | DiceMsg Dice.Msg.Msg
    | ModalStackMsg ModalStack.Msg.Msg
    | StatsMsg Stats.Msg.Msg
    | ImportExportMsg ImportExport.Msg.Msg
    | Roll
    | Score Scoreboard.Model.ScoreKey
    | Undo
    | NewGame
    | ToggleMenu
    | UpdateAspectRatio Float
    | PersistState
    | TryPersistGame
    | PersistGame Scoreboard.Model.Model Time.Posix
    | InitTimeZone Time.Zone
    | NoOp
