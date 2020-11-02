module Stats.Msg exposing (Msg(..))

import Stats.Model exposing (Game)


type Msg
    = Init (List Game)
    | Update Game
