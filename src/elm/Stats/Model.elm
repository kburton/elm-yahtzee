module Stats.Model exposing (Model, defaultModel)

import Ports


type alias Model =
    { gamesPlayed : Int
    , games200 : Int
    , games300 : Int
    , games400 : Int
    , yahtzees : Int
    , yahtzeeBonuses : Int
    , highScoreGames : List Ports.GameModel
    }


defaultModel : Model
defaultModel =
    { gamesPlayed = 0
    , games200 = 0
    , games300 = 0
    , games400 = 0
    , yahtzees = 0
    , yahtzeeBonuses = 0
    , highScoreGames = []
    }
