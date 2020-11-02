port module Persistence.Ports exposing
    ( exportHistory
    , exportHistoryResponse
    , importHistory
    , importHistoryCheck
    , importHistoryCheckFailure
    , importHistoryCheckSuccess
    , importHistoryFailure
    , importHistorySuccess
    , persistCompletedGame
    , persistGameState
    )

import Persistence.Model exposing (PersistedGame, PersistedGameHistory, PersistedGameState)


port persistGameState : PersistedGameState -> Cmd msg


port persistCompletedGame : PersistedGame -> Cmd msg


port exportHistory : () -> Cmd msg


port exportHistoryResponse : (String -> msg) -> Sub msg


port importHistoryCheck : String -> Cmd msg


port importHistoryCheckSuccess : (PersistedGameHistory -> msg) -> Sub msg


port importHistoryCheckFailure : (String -> msg) -> Sub msg


port importHistory : String -> Cmd msg


port importHistorySuccess : (PersistedGameHistory -> msg) -> Sub msg


port importHistoryFailure : (String -> msg) -> Sub msg
