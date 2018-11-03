module Types exposing (Model, Msg(..))

import Game.Types
import Html.Styled exposing (Html)


type alias Model =
    { game : Game.Types.Model
    , menuOpen : Bool
    , modal : Maybe ( String, List ( String, Html Msg ) )
    }


type Msg
    = GameMsg Game.Types.Msg
    | ToggleMenu
    | OpenModal ( String, List ( String, Html Msg ) )
    | CloseModal
    | NoOp
