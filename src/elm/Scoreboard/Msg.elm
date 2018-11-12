module Scoreboard.Msg exposing (Msg(..))

import Scoreboard.Model exposing (..)


type Msg
    = Score ScoreKey
    | Reset
