module View.Stats exposing (stats)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Modal.Model as Modal
import Msg exposing (Msg)
import Stats.Model exposing (Model)


stats : Model -> Modal.Model
stats model =
    { title = "Stats"
    , sections =
        [ { header = "Stats"
          , content =
                div
                    [ class "stats" ]
                    [ statsDivider
                    , stat "High score" <| String.fromInt model.highScore
                    , stat "Games played" <| String.fromInt model.gamesPlayed
                    , statsDivider
                    , stat "Yahtzees scored" <| String.fromInt model.yahtzees
                    , stat "Yahtzee bonuses" <| String.fromInt model.yahtzeeBonuses
                    , statsDivider
                    , stat "Games scoring 200+" <| String.fromInt model.games200
                    , stat "Games scoring 300+" <| String.fromInt model.games300
                    , stat "Games scoring 400+" <| String.fromInt model.games400
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
