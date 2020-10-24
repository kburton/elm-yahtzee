module ModelWrapper exposing (ModelWrapper)

import Modal.Model
import Model exposing (Model)


type alias ModelWrapper =
    { model : Model
    , modalStack : List (Model -> Modal.Model.Model)
    }
