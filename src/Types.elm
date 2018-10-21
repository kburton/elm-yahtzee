module Types exposing (Model, Msg(..))

import Dice.Types


type alias Model =
    { dice : Dice.Types.Model }


type Msg
    = DiceMsg Dice.Types.Msg
