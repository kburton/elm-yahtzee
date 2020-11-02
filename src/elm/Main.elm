module Main exposing (main)

import Browser
import Model exposing (Model)
import Msg exposing (Msg)
import Persistence.Flags exposing (Flags)
import State
import View


main : Program (Maybe Flags) Model Msg
main =
    Browser.element
        { init = State.init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.view
        }
