module Msg exposing (Msg(..))

import Dice.Msg
import ModalStack.Msg
import Persistence.Msg
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
    | Undo
    | NewGame
    | UpdateAspectRatio Float
    | InitTimeZone Time.Zone
    | NoOp
