module Scoreboard.Msg exposing (Msg(..))

import Scoreboard.Model exposing (ScoreKey)


type Msg
    = Score ScoreKey
    | Reset
