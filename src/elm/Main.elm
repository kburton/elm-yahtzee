module Main exposing (main)

import Browser
import Model exposing (Model)
import Msg exposing (Msg)
import Persistence.Flags exposing (Flags)
import Router.Msg
import State
import View


main : Program (Maybe Flags) Model Msg
main =
    Browser.application
        { init = State.init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.view
        , onUrlRequest = Msg.RouterMsg << Router.Msg.UrlRequested
        , onUrlChange = Msg.RouterMsg << Router.Msg.UrlChanged
        }
