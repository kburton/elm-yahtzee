module Stats.Msg exposing (Msg(..))

import Ports


type Msg
    = Init Ports.HistoryModel
    | Update Ports.GameModel
