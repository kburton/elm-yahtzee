module View.Modals.Menu exposing (menu)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import ModalStack.Model
import ModalStack.Msg
import Model exposing (Model)
import Msg exposing (Msg)


menu : Model -> ModalStack.Model.Modal Msg
menu _ =
    { title = "Menu"
    , body = ModalStack.Model.Raw menuBody
    }


menuBody : Html Msg
menuBody =
    div
        [ class "menu" ]
        [ menuItem "Stats" <| Msg.ModalStackMsg ModalStack.Msg.ShowStats
        , menuItem "New game" Msg.NewGame
        , menuItem "Import / Export" <| Msg.ModalStackMsg ModalStack.Msg.ShowImportExport
        , menuItem "Credits" <| Msg.ModalStackMsg ModalStack.Msg.ShowCredits
        ]


menuItem : String -> Msg -> Html Msg
menuItem content msg =
    div
        [ class "menu__item", onClick msg ]
        [ text content ]
