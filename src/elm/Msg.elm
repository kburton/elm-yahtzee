module Msg exposing (Msg(..))

import Dice.Msg
import Help.Model
import Scoreboard.Model
import Scoreboard.Msg
import Time


type Msg
    = ScoreboardMsg Scoreboard.Msg.Msg
    | DiceMsg Dice.Msg.Msg
    | Roll
    | Score Scoreboard.Model.ScoreKey
    | Undo
    | NewGame
    | ToggleMenu
    | ShowHelp Help.Model.HelpKey
    | CloseModal
    | UpdateAspectRatio Float
    | PersistState
    | TryPersistGame
    | PersistGame Scoreboard.Model.Model Time.Posix
    | NoOp
