module Modal.Model exposing (Body(..), Model, Section)

import Html exposing (Html)


type alias Model msg =
    { title : String
    , body : Body msg
    }


type Body msg
    = Sections (List (Section msg))
    | Raw (Html msg)


type alias Section msg =
    { header : String
    , content : Html msg
    }
