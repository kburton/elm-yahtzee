module Model exposing (Model, UndoState)

import Dice.Model as Dice
import Modal.Model as Modal
import Scoreboard.Model as Scoreboard
import Stats.Model as Stats


type alias Model =
    { scoreboard : Scoreboard.Model
    , dice : Dice.Model
    , stats : Stats.Model
    , roll : Int
    , tutorialMode : Bool
    , menuOpen : Bool
    , modalStack : List Modal.Model
    , aspectRatio : Maybe Float
    , undo : Maybe UndoState
    }


type alias UndoState =
    { scoreboard : Scoreboard.Model
    , dice : Dice.Model
    , roll : Int
    , lastScoreKey : Scoreboard.ScoreKey
    }
