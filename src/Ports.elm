port module Ports exposing (Flags, GameStateModel, fromGameStateModel, persistCompletedGame, persistGameState, toGameModel, toGameStateModel)

import Dict
import Game.Scoreboard
import Game.Types
import Time


type alias Flags =
    { gameState : Maybe GameStateModel
    , history : Maybe HistoryModel
    }


type alias GameStateModel =
    { scoreboard : List ( Int, Int )
    , turn : Int
    , roll : Int
    , dice : Game.Types.Dice
    , tutorialMode : Bool
    }


type alias HistoryModel =
    List GameModel


type alias GameModel =
    { v : Int
    , t : Int
    , g : Int
    , s : List ( Int, Int )
    }


currentVersion : Int
currentVersion =
    1


toGameStateModel : Game.Types.Model -> GameStateModel
toGameStateModel model =
    { scoreboard = Dict.toList model.scoreboard
    , turn = model.turn
    , roll = model.roll
    , dice = model.dice
    , tutorialMode = model.tutorialMode
    }


fromGameStateModel : Game.Types.Model -> GameStateModel -> Game.Types.Model
fromGameStateModel model gameStateModel =
    { model
        | scoreboard = Dict.fromList gameStateModel.scoreboard
        , turn = gameStateModel.turn
        , roll = gameStateModel.roll
        , dice = gameStateModel.dice
        , tutorialMode = gameStateModel.tutorialMode
    }


toGameModel : Game.Types.Model -> Time.Posix -> GameModel
toGameModel model time =
    { v = currentVersion
    , t = Time.posixToMillis time
    , g = Game.Scoreboard.grandTotal model.scoreboard
    , s = Dict.toList model.scoreboard
    }


port persistGameState : GameStateModel -> Cmd msg


port persistCompletedGame : GameModel -> Cmd msg
