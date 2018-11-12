module Modal.Model exposing (Model, Section)

import Html exposing (Html)
import Msg exposing (Msg)


type alias Model =
    { title : String
    , sections : List Section
    }


type alias Section =
    { header : String
    , content : Html Msg
    }
