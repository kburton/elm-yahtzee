module Types exposing (Model, Msg(..))

import Browser.Dom
import Game.Types
import Html exposing (Html)


type alias Model =
    { game : Game.Types.Model
    , menuOpen : Bool
    , modal : Maybe ( String, List ( String, Html Msg ) )
    , aspectRatio : Maybe Float
    }


type Msg
    = GameMsg Game.Types.Msg
    | ToggleMenu
    | OpenModal ( String, List ( String, Html Msg ) )
    | CloseModal
    | UpdateAspectRatio Float
    | NoOp
