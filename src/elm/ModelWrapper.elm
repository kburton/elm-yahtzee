module ModelWrapper exposing (ModelWrapper)

import Modal.Model
import Model exposing (Model)
import Msg


type alias ModalWrapper =
    { modal : Model -> Modal.Model.Model
    , onClose : Msg.Msg
    }


type alias ModelWrapper =
    { model : Model
    , modalStack : List ModalWrapper
    }
