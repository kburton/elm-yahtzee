module Model exposing (Model, UndoState)

import Dice.Model
import Modal.Model
import Scoreboard.Model


type alias Model =
    { scoreboard : Scoreboard.Model.Model
    , dice : Dice.Model.Model
    , roll : Int
    , tutorialMode : Bool
    , menuOpen : Bool
    , modalStack : List Modal.Model.Model
    , aspectRatio : Maybe Float
    , gamesPlayed : Int
    , highScore : Int
    , undo : Maybe UndoState
    }


type alias UndoState =
    { scoreboard : Scoreboard.Model.Model
    , dice : Dice.Model.Model
    , roll : Int
    , lastScoreKey : Scoreboard.Model.ScoreKey
    }
