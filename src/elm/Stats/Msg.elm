module Stats.Msg exposing (Msg(..))

import Scoreboard.Model


type Msg
    = Update Scoreboard.Model.Model
