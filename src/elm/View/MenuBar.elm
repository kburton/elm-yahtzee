module View.MenuBar exposing (menuBar)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Msg exposing (Msg)
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt


menuBar : Bool -> Html Msg
menuBar menuIsOpen =
    let
        title =
            if menuIsOpen then
                "Menu"

            else
                "Elm Yahtzee"
    in
    div
        [ class "menu-bar" ]
        [ div [] [ text title ]
        , button
        ]


button : Html Msg
button =
    Svg.svg
        [ SvgAtt.viewBox "0 0 32 24"
        , SvgAtt.class "menu-bar__button"
        , SvgEvt.onClick Msg.ToggleMenu
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
