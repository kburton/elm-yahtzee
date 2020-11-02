module Stats.Model exposing (Game, Model, defaultModel, makeGame)

import Scoreboard.Model
import Scoreboard.Summary
import Time


type alias Model =
    { gamesPlayed : Int
    , games200 : Int
    , games300 : Int
    , games400 : Int
    , yahtzees : Int
    , yahtzeeBonuses : Int
    , highScoreGames : List Game
    }


type alias Game =
    { scoreboard : Scoreboard.Model.Model
    , score : Int
    , timestamp : Time.Posix
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


makeGame : Scoreboard.Model.Model -> Time.Posix -> Game
makeGame scoreboard timestamp =
    { scoreboard = scoreboard
    , score = Scoreboard.Summary.grandTotal scoreboard
    , timestamp = timestamp
    }
