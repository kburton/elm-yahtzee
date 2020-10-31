module View.Modals.Credits exposing (credits)

import Html exposing (a, div, p, text)
import Html.Attributes exposing (href, target)
import ModalStack.Model
import Model exposing (Model)
import Msg exposing (Msg)


credits : Model -> ModalStack.Model.Modal Msg
credits _ =
    { title = "Credits"
    , body =
        ModalStack.Model.Sections
            [ { header = "Project"
              , content =
                    div
                        []
                        [ p
                            []
                            [ text "Elm Yahtzee is written in "
                            , a [ href "https://elm-lang.org/", target "_blank" ] [ text "elm" ]
                            , text ", a functional language that compiles to JavaScript."
                            ]
                        , p
                            []
                            [ text "The project is open source and licensed under the "
                            , a [ href "https://choosealicense.com/licenses/gpl-3.0/", target "_blank" ] [ text "GNU General Public License v3.0" ]
                            , text "."
                            ]
                        , p
                            []
                            [ text "View the code on "
                            , a [ href "https://github.com/kburton/elm-yahtzee", target "_blank" ] [ text "GitHub" ]
                            , text "."
                            ]
                        ]
              }
            , { header = "Resources"
              , content =
                    div
                        []
                        [ p
                            []
                            [ text "Paper texture from "
                            , a [ href "https://www.toptal.com/designers/subtlepatterns/paper/", target "_blank" ] [ text "Toptal Subtle Patterns" ]
                            , text " and created by Blaq Annabiosis."
                            ]
                        , p
                            []
                            [ text "Kalam handwriting font from "
                            , a [ href "https://fonts.google.com/specimen/Kalam", target "_blank" ] [ text "Google fonts" ]
                            , text "."
                            ]
                        ]
              }
            ]
    }
