module Types exposing (Model, Msg(..))

import Game.Types


type alias Model =
    { game : Game.Types.Model
    }


type Msg
    = GameMsg Game.Types.Msg
