module Router.State exposing (init, update)

import Browser.Navigation
import Router.Model exposing (Model, modalCount)
import Router.Msg exposing (Msg(..))
import Url exposing (Url)


init : Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init url navKey =
    ( { navKey = navKey
      , currentUrl = url
      }
    , case url.fragment of
        Just _ ->
            Browser.Navigation.replaceUrl navKey <| Url.toString { url | fragment = Nothing }

        Nothing ->
            Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateFragment newModalCount ->
            let
                currentUrl =
                    model.currentUrl

                currentModalCount =
                    modalCount model
            in
            ( model
            , if newModalCount > currentModalCount then
                Browser.Navigation.pushUrl model.navKey <| Url.toString <| { currentUrl | fragment = Just <| String.fromInt newModalCount }

              else if newModalCount < currentModalCount then
                Browser.Navigation.back model.navKey 1

              else
                Cmd.none
            )

        UrlRequested _ ->
            ( model, Cmd.none )

        UrlChanged url ->
            ( { model | currentUrl = url }, Cmd.none )
