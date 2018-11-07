port module Ports exposing (GameStateModel, fromGameStateModel, persistGameState, toGameStateModel)

import Dict
import Game.Types exposing (..)


type alias GameStateModel =
    { scoreboard : List ( Int, Int )
    , turn : Int
    , roll : Int
    , dice : Dice
    , tutorialMode : Bool
    }


toGameStateModel : Model -> GameStateModel
toGameStateModel model =
    { scoreboard = Dict.toList model.scoreboard
    , turn = model.turn
    , roll = model.roll
    , dice = model.dice
    , tutorialMode = model.tutorialMode
    }


fromGameStateModel : Model -> GameStateModel -> Model
fromGameStateModel model gameStateModel =
    { model
        | scoreboard = Dict.fromList gameStateModel.scoreboard
        , turn = gameStateModel.turn
        , roll = gameStateModel.roll
        , dice = gameStateModel.dice
        , tutorialMode = gameStateModel.tutorialMode
    }


port persistGameState : GameStateModel -> Cmd msg
