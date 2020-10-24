module Model exposing (Model, UndoState)

import Dice.Model
import ImportExport.Model
import Scoreboard.Model
import Stats.Model


type alias Model =
    { scoreboard : Scoreboard.Model.Model
    , dice : Dice.Model.Model
    , stats : Stats.Model.Model
    , importExport : ImportExport.Model.Model
    , roll : Int
    , tutorialMode : Bool
    , menuOpen : Bool
    , aspectRatio : Maybe Float
    , undo : Maybe UndoState
    }


type alias UndoState =
    { scoreboard : Scoreboard.Model.Model
    , dice : Dice.Model.Model
    , roll : Int
    , lastScoreKey : Scoreboard.Model.ScoreKey
    }
