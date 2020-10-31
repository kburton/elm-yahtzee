module Model exposing (ModalStack(..), Model, UndoState)

import Dice.Model
import ImportExport.Model
import ModalStack.Model
import Msg
import Scoreboard.Model
import Stats.Model
import Time


type alias Model =
    { scoreboard : Scoreboard.Model.Model
    , dice : Dice.Model.Model
    , modalStack : ModalStack
    , stats : Stats.Model.Model
    , importExport : ImportExport.Model.Model
    , roll : Int
    , tutorialMode : Bool
    , menuOpen : Bool
    , aspectRatio : Maybe Float
    , undo : Maybe UndoState
    , timeZone : Time.Zone
    }


type ModalStack
    = ModalStack (ModalStack.Model.Model Model Msg.Msg)


type alias UndoState =
    { scoreboard : Scoreboard.Model.Model
    , dice : Dice.Model.Model
    , roll : Int
    , lastScoreKey : Scoreboard.Model.ScoreKey
    }
