port module Ports exposing (persistGameState, toGameStateModel)

import Dict
import Game.Types exposing (..)


type alias GameStateModel =
    { game : List ( Int, Int )
    , turn : Int
    , roll : Int
    , dice : Dice
    , tutorialMode : Bool
    }


fromGameStateModel : GameStateModel -> Model
fromGameStateModel gameStateModel =



toGameStateModel : Model -> GameStateModel
toGameStateModel model =
    { game = Dict.toList <| Game.Types.currentGame model
    , turn = model.turn
    , roll = model.roll
    , dice = model.dice
    , tutorialMode = model.tutorialMode
    }


port persistGameState : GameStateModel -> Cmd msg
