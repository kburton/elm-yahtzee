module Msg exposing (Msg(..))

import Dice.Msg
import ModalStack.Msg
import Persistence.Msg
import Scoreboard.Model
import Scoreboard.Msg
import Stats.Msg
import Time


type Msg
    = ScoreboardMsg Scoreboard.Msg.Msg
    | DiceMsg Dice.Msg.Msg
    | ModalStackMsg ModalStack.Msg.Msg
    | StatsMsg Stats.Msg.Msg
    | PersistenceMsg Persistence.Msg.Msg
    | Roll
    | Score Scoreboard.Model.ScoreKey
    | Undo
    | NewGame
    | ToggleMenu
    | UpdateAspectRatio Float
    | InitTimeZone Time.Zone
    | NoOp
