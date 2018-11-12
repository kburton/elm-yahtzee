module Dice.Model exposing (Die, Face, Index, Model, active, anyRolling, defaultModel, dieAt, faces, rolling)

import Array exposing (Array)


type alias Model =
    Array Die


type alias Die =
    { face : Face
    , flipsLeft : Int
    , locked : Bool
    }


type alias Face =
    Int


type alias Index =
    Int


defaultModel : Model
defaultModel =
    Array.repeat 5 defaultDie


defaultDie : Die
defaultDie =
    { face = 1
    , flipsLeft = 0
    , locked = False
    }


dieAt : Index -> Model -> Die
dieAt index model =
    Maybe.withDefault defaultDie <| Array.get index model


active : Model -> List ( Index, Die )
active model =
    List.filter (\( _, d ) -> not d.locked) <| Array.toIndexedList model


rolling : Model -> List ( Index, Die )
rolling model =
    List.filter (\( _, d ) -> d.flipsLeft > 0) <| Array.toIndexedList model


anyRolling : Model -> Bool
anyRolling model =
    List.any (\d -> d.flipsLeft > 0) <| Array.toList model


faces : Model -> List Int
faces model =
    List.map .face <| Array.toList model
