module View.Modal exposing (modal)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Modal.Model exposing (Model, Section)
import Msg exposing (Msg)
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt


modal : Model -> Html Msg
modal model =
    div
        [ class "modal" ]
        [ header model
        , body model
        ]


header : Model -> Html Msg
header model =
    div
        [ class "modal__header" ]
        [ title model.title
        , close
        ]


body : Model -> Html Msg
body model =
    div
        [ class "modal__body" ]
        (List.map section model.sections)


title : String -> Html Msg
title t =
    div
        [ class "modal__title" ]
        [ text t ]


close : Html Msg
close =
    Svg.svg
        [ SvgAtt.viewBox "0 0 12 12"
        , SvgAtt.class "modal__close"
        , SvgEvt.onClick Msg.CloseModal
        ]
        [ Svg.line [ SvgAtt.x1 "1", SvgAtt.y1 "11", SvgAtt.x2 "11", SvgAtt.y2 "1", SvgAtt.strokeWidth "2", SvgAtt.strokeLinecap "round" ] []
        , Svg.line [ SvgAtt.x1 "1", SvgAtt.y1 "1", SvgAtt.x2 "11", SvgAtt.y2 "11", SvgAtt.strokeWidth "2", SvgAtt.strokeLinecap "round" ] []
        ]


section : Section -> Html Msg
section s =
    div
        [ class "modal__section" ]
        [ div [ class "modal__section-header" ] [ text s.header ]
        , div [ class "modal__section-content" ] [ s.content ]
        ]
