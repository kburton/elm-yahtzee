module Stats.Msg exposing (Msg(..))

import Ports
import Scoreboard.Model


type Msg
    = Init Ports.HistoryModel
    | Update Scoreboard.Model.Model
