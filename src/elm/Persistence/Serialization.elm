module Persistence.Serialization exposing
    ( deserializeGame
    , deserializeGameHistory
    , deserializeGameState
    , serializeGame
    , serializeGameState
    )

import Array
import Dict
import Model exposing (GameState)
import Persistence.Model exposing (GameHistory, PersistedGame, PersistedGameHistory, PersistedGameState)
import Stats.Model
import Time


serializeGameState : GameState -> PersistedGameState
serializeGameState gameState =
    { scoreboard = Dict.toList gameState.scoreboard
    , dice = Array.toList gameState.dice
    , roll = gameState.roll
    }


deserializeGameState : Maybe PersistedGameState -> Maybe GameState
deserializeGameState persistedGameState =
    Maybe.map
        (\state ->
            { scoreboard = Dict.fromList state.scoreboard
            , dice = Array.fromList state.dice
            , roll = state.roll
            }
        )
        persistedGameState


serializeGame : Stats.Model.Game -> PersistedGame
serializeGame game =
    { v = 1
    , t = Time.posixToMillis game.timestamp
    , g = game.score
    , s = Dict.toList game.scoreboard
    }


deserializeGame : PersistedGame -> Stats.Model.Game
deserializeGame persistedGame =
    { scoreboard = Dict.fromList persistedGame.s
    , score = persistedGame.g
    , timestamp = Time.millisToPosix persistedGame.t
    }


deserializeGameHistory : Maybe PersistedGameHistory -> GameHistory
deserializeGameHistory persistedGameHistory =
    case persistedGameHistory of
        Just history ->
            List.map deserializeGame history

        Nothing ->
            []
