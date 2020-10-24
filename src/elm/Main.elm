module Main exposing (main)

import Browser
import ModelWrapper
import Msg
import Ports
import State
import View


main : Program (Maybe Ports.Flags) ModelWrapper.ModelWrapper Msg.Msg
main =
    Browser.element
        { init = State.init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.view
        }
