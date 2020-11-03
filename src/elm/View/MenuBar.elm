module View.MenuBar exposing (menuBar)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import ModalStack.Msg
import Msg exposing (Msg)
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt


menuBar : Html Msg
menuBar =
    div
        [ class "menu-bar" ]
        [ div [] [ text "Elm Yahtzee" ]
        , button
        ]


button : Html Msg
button =
    Svg.svg
        [ SvgAtt.viewBox "0 0 32 24"
        , SvgAtt.class "menu-bar__button"
        , SvgEvt.onClick <| Msg.ModalStackMsg ModalStack.Msg.ShowMenu
        ]
        [ Svg.rect
            [ SvgAtt.x "0"
            , SvgAtt.y "0"
            , SvgAtt.width "32"
            , SvgAtt.height "4"
            , SvgAtt.rx "2"
            , SvgAtt.ry "2"
            ]
            []
        , Svg.rect
            [ SvgAtt.x "0"
            , SvgAtt.y "10"
            , SvgAtt.width "32"
            , SvgAtt.height "4"
            , SvgAtt.rx "2"
            , SvgAtt.ry "2"
            ]
            []
        , Svg.rect
            [ SvgAtt.x "0"
            , SvgAtt.y "20"
            , SvgAtt.width "32"
            , SvgAtt.height "4"
            , SvgAtt.rx "2"
            , SvgAtt.ry "2"
            ]
            []
        ]
