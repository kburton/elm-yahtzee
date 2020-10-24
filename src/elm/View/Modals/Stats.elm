module View.Modals.Stats exposing (stats)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Modal.Model as Modal
import Model exposing (Model)
import Msg exposing (Msg)


stats : Model -> Modal.Model
stats model =
    { title = "Stats"
    , sections =
        [ { header = "Stats"
          , content =
                div
                    [ class "stats" ]
                    [ statsDivider
                    , stat "High score" <| String.fromInt model.stats.highScore
                    , stat "Games played" <| String.fromInt model.stats.gamesPlayed
                    , statsDivider
                    , stat "Yahtzees scored" <| String.fromInt model.stats.yahtzees
                    , stat "Yahtzee bonuses" <| String.fromInt model.stats.yahtzeeBonuses
                    , statsDivider
                    , stat "Games scoring 200+" <| String.fromInt model.stats.games200
                    , stat "Games scoring 300+" <| String.fromInt model.stats.games300
                    , stat "Games scoring 400+" <| String.fromInt model.stats.games400
                    , statsDivider
                    ]
          }
        ]
    }


stat : String -> String -> Html Msg
stat label value =
    div
        [ class "stats__stat" ]
        [ div [ class "stats__label" ] [ text label ]
        , div [ class "stats__value" ] [ text value ]
        ]


statsDivider : Html msg
statsDivider =
    div [ class "stats__divider" ] []
