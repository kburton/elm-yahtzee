module View.Modal exposing (modal)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import ModalStack.Model exposing (Body(..), Modal, Section)
import ModalStack.Msg
import Msg exposing (Msg)
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt


modal : Modal Msg -> Html Msg
modal model =
    div
        [ class "modal" ]
        [ header model
        , body model
        ]


header : Modal Msg -> Html Msg
header model =
    div
        [ class "modal__header" ]
        [ title model.title
        , close
        ]


body : Modal Msg -> Html Msg
body model =
    let
        ( classModifier, bodyContent ) =
            case model.body of
                Raw content ->
                    ( "raw", [ content ] )

                Sections sections ->
                    ( "sections", List.map section sections )
    in
    div
        [ class <| "modal__body modal__body--" ++ classModifier ]
        bodyContent


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
        , SvgEvt.onClick <| Msg.ModalStackMsg ModalStack.Msg.Close
        ]
        [ Svg.line [ SvgAtt.x1 "1", SvgAtt.y1 "11", SvgAtt.x2 "11", SvgAtt.y2 "1", SvgAtt.strokeWidth "2", SvgAtt.strokeLinecap "round" ] []
        , Svg.line [ SvgAtt.x1 "1", SvgAtt.y1 "1", SvgAtt.x2 "11", SvgAtt.y2 "11", SvgAtt.strokeWidth "2", SvgAtt.strokeLinecap "round" ] []
        ]


section : Section Msg -> Html Msg
section s =
    div
        [ class "modal__section" ]
        [ div [ class "modal__section-header" ] [ text s.header ]
        , div [ class "modal__section-content" ] [ s.content ]
        ]
