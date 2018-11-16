module View.Menu exposing (menu)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Msg exposing (Msg)
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt


menu : Html Msg
menu =
    div
        [ class "menu" ]
        [ menuItem "Stats" Msg.ShowStats
        , menuItem "New game" Msg.NewGame
        ]


menuItem : String -> Msg -> Html Msg
menuItem content msg =
    div
        [ class "menu__item", onClick msg ]
        [ text content ]
