module View.Modals.Stats exposing (stats)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import ModalStack.Model as Modal
import ModalStack.Msg
import Model exposing (Model)
import Msg exposing (Msg)
import Stats.Model exposing (Game)
import Time
import Utils.Date exposing (formatDate)


stats : Model -> Modal.Modal Msg
stats model =
    { title = "Stats"
    , body =
        Modal.Sections
            ({ header = "Summary"
             , content =
                div
                    [ class "stats" ]
                    [ stat "Games played" <| String.fromInt model.stats.gamesPlayed
                    , stat "Yahtzees scored" <| String.fromInt model.stats.yahtzees
                    , stat "Yahtzee bonuses" <| String.fromInt model.stats.yahtzeeBonuses
                    , stat "Games scoring 200+" <| String.fromInt model.stats.games200
                    , stat "Games scoring 300+" <| String.fromInt model.stats.games300
                    , stat "Games scoring 400+" <| String.fromInt model.stats.games400
                    ]
             }
                :: highScoreGames model.timeZone model.stats.highScoreGames
            )
    }


stat : String -> String -> Html Msg
stat label value =
    div
        [ class "stats__stat" ]
        [ div [ class "stats__label" ] [ text label ]
        , div [ class "stats__value" ] [ text value ]
        ]


highScoreGames : Time.Zone -> List Game -> List (Modal.Section Msg)
highScoreGames tz games =
    if List.isEmpty games then
        []

    else
        [ { header = "High Scores"
          , content = div [] (List.map (highScoreGame tz) games)
          }
        ]


highScoreGame : Time.Zone -> Game -> Html Msg
highScoreGame tz game =
    div
        [ class "stats__high-score-game", onClick <| Msg.ModalStackMsg (ModalStack.Msg.ShowCompletedGame game) ]
        [ div [ class "stats__label" ] [ text <| formatDate tz <| game.timestamp ]
        , div [ class "stats__value" ] [ text <| String.fromInt game.score ++ " points" ]
        ]
