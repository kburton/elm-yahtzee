module Persistence.Flags exposing (Flags)

import Persistence.Model exposing (PersistedGameHistory, PersistedGameState)


type alias Flags =
    { gameState : Maybe PersistedGameState
    , history : Maybe PersistedGameHistory
    }
