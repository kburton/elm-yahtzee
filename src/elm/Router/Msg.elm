module Router.Msg exposing (Msg(..))

import Browser
import Url exposing (Url)


type Msg
    = UpdateFragment Int
    | UrlRequested Browser.UrlRequest
    | UrlChanged Url
