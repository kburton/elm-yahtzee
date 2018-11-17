module Dice.Msg exposing (Msg(..))

import Dice.Model exposing (Face, Index)


type Msg
    = Roll
    | SetFlips Index Int
    | Flip Index
    | NewFace Index Face
    | ToggleLock Index
    | Reset
