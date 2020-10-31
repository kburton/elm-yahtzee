module Modal.Model exposing (Body(..), Model, Section)

import Html exposing (Html)
import Msg exposing (Msg)


type alias Model =
    { title : String
    , body : Body
    }


type Body
    = Sections (List Section)
    | Raw (Html Msg)


type alias Section =
    { header : String
    , content : Html Msg
    }
