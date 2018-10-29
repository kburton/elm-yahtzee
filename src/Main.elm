module Main exposing (main)

import Browser
import Html.Styled exposing (toUnstyled)
import State
import View


main =
    Browser.element
        { init = State.init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.view >> toUnstyled
        }
