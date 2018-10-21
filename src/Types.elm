module Types exposing (Model, Msg(..))

import Dice.Types
import Game.Types


type alias Model =
    { dice : Dice.Types.Model
    , game : Game.Types.Model
    }


type Msg
    = DiceMsg Dice.Types.Msg
    | GameMsg Game.Types.Msg
