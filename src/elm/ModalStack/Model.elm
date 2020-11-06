module ModalStack.Model exposing (Body(..), Modal, Model, Section, modalCount)

import Html exposing (Html)


type alias Model model msg =
    List (ActiveModal model msg)


type alias ActiveModal model msg =
    { modal : model -> Modal msg
    , onClose : msg
    }


type alias Modal msg =
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


modalCount : Model model msg -> Int
modalCount =
    List.length
