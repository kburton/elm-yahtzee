module Dice.Types exposing (Die, Face, Index, Model, Msg(..), activeDice, rollingDice)

import Array exposing (Array)


type alias Model =
    { dice : Array Die
    }


type Msg
    = RollAll
    | SetFlips Index Int
    | Flip Index
    | NewFace Index Face
    | ToggleLock Index


type alias Index =
    Int


type alias Face =
    Int


type alias Die =
    { face : Face
    , flipsLeft : Int
    , locked : Bool
    }


activeDice : Model -> List ( Index, Die )
activeDice model =
    Array.toList <| Array.filter (\( i, d ) -> not d.locked) <| Array.indexedMap (\i d -> ( i, d )) model.dice


rollingDice : Model -> List ( Index, Int )
rollingDice model =
    Array.toList <| Array.filter (\( i, f ) -> f > 0) <| Array.indexedMap (\i d -> ( i, d.flipsLeft )) model.dice
