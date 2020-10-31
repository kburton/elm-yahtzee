module Model exposing (ActiveModal, ModalStack(..), Model, UndoState)

import Dice.Model
import ImportExport.Model
import Modal.Model
import Msg
import Scoreboard.Model
import Stats.Model
import Time


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
    , timeZone : Time.Zone
    , modalStack : ModalStack
    }


type ModalStack
    = ModalStack (List ActiveModal)


type alias ActiveModal =
    { modal : Model -> Modal.Model.Model Msg.Msg
    , onClose : Msg.Msg
    }


type alias UndoState =
    { scoreboard : Scoreboard.Model.Model
    , dice : Dice.Model.Model
    , roll : Int
    , lastScoreKey : Scoreboard.Model.ScoreKey
    }
