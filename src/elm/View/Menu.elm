module View.Menu exposing (menu)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import ModalStack.Msg
import Msg exposing (Msg)


menu : Html Msg
menu =
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
