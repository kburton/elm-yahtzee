port module Ports exposing (Flags, GameModel, GameStateModel, persistCompletedGame, persistGameState)

import Dice.Model


type alias Flags =
    { gameState : Maybe GameStateModel
    , history : Maybe HistoryModel
    }


type alias GameStateModel =
    { scoreboard : List ( Int, Int )
    , roll : Int
    , dice : List Dice.Model.Die
    , tutorialMode : Bool
    }


type alias HistoryModel =
    List GameModel


type alias GameModel =
    { v : Int -- version
    , t : Int -- timestamp
    , g : Int -- grand total
    , s : List ( Int, Int ) -- scoreboard
    }


port persistGameState : GameStateModel -> Cmd msg


port persistCompletedGame : GameModel -> Cmd msg
