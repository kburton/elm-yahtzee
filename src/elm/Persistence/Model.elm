module Persistence.Model exposing (GameHistory, ImportStage(..), Model, PersistedGame, PersistedGameHistory, PersistedGameState, defaultModel)

import Dice.Model
import Stats.Model


type ImportStage
    = ImportStageNone
    | ImportStageUploaded String
    | ImportStageChecked { uploadedContent : String, result : Result String PersistedGameHistory }
    | ImportStageImported (Result String ())


type alias Model =
    { importStage : ImportStage
    }


type alias GameHistory =
    List Stats.Model.Game


type alias PersistedGameState =
    { scoreboard : List ( Int, Int )
    , dice : List Dice.Model.Die
    , roll : Int
    }


type alias PersistedGame =
    { v : Int -- version
    , t : Int -- timestamp
    , g : Int -- grand total
    , s : List ( Int, Int ) -- scoreboard
    }


type alias PersistedGameHistory =
    List PersistedGame


defaultModel : Model
defaultModel =
    { importStage = ImportStageNone
    }
