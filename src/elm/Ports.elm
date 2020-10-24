port module Ports exposing
    ( Flags
    , GameModel
    , HistoryModel
    , exportHistory
    , exportHistoryResponse
    , importHistory
    , importHistoryCheck
    , importHistoryFailure
    , importHistorySuccess
    , persistCompletedGame
    , persistGameState
    )

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


port exportHistory : () -> Cmd msg


port exportHistoryResponse : (String -> msg) -> Sub msg


port importHistory : String -> Cmd msg


port importHistoryCheck : (HistoryModel -> msg) -> Sub msg


port importHistorySuccess : (HistoryModel -> msg) -> Sub msg


port importHistoryFailure : (String -> msg) -> Sub msg
