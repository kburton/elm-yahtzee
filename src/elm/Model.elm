module Model exposing (GameState, ModalStack(..), Model, UndoState, defaultGameState)

import Dice.Model
import ModalStack.Model
import Msg
import Persistence.Model
import Scoreboard.Model
import Stats.Model
import Time


type alias Model =
    { game : GameState
    , modalStack : ModalStack
    , stats : Stats.Model.Model
    , persistence : Persistence.Model.Model
    , tutorialMode : Bool
    , menuOpen : Bool
    , aspectRatio : Maybe Float
    , undo : Maybe UndoState
    , timeZone : Time.Zone
    }


type ModalStack
    = ModalStack (ModalStack.Model.Model Model Msg.Msg)


type alias GameState =
    { scoreboard : Scoreboard.Model.Model
    , dice : Dice.Model.Model
    , roll : Int
    }


type alias UndoState =
    { scoreboard : Scoreboard.Model.Model
    , dice : Dice.Model.Model
    , roll : Int
    , lastScoreKey : Scoreboard.Model.ScoreKey
    }


defaultGameState : GameState
defaultGameState =
    { scoreboard = Scoreboard.Model.defaultModel
    , dice = Dice.Model.defaultModel
    , roll = 1
    }
