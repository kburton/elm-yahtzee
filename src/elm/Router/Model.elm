module Router.Model exposing (Model, modalCount)

import Browser.Navigation
import Url exposing (Url)


type alias Model =
    { navKey : Browser.Navigation.Key
    , currentUrl : Url
    }


modalCount : Model -> Int
modalCount model =
    Maybe.withDefault 0 <| String.toInt <| Maybe.withDefault "" model.currentUrl.fragment
