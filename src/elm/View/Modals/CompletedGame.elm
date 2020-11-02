module View.Modals.CompletedGame exposing (completedGame)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import ModalStack.Model
import Model exposing (Model)
import Msg exposing (Msg)
import Scoreboard.Model
import Stats.Model exposing (Game)
import Utils.Date exposing (formatDate)
import View.Scoreboard


completedGame : Game -> Model -> ModalStack.Model.Modal Msg
completedGame game model =
    { title = "Game Details"
    , body = ModalStack.Model.Raw <| div [ class "completed-game" ] [ summary game model, scoreboard game ]
    }


summary : Game -> Model -> Html Msg
summary game model =
    div
        [ class "completed-game__summary" ]
        [ div [] [ text <| formatDate model.timeZone <| game.timestamp ]
        , div [] [ text <| String.fromInt game.score ++ " points" ]
        ]


scoreboard : Game -> Html Msg
scoreboard game =
    div
        [ class "completed-game__scoreboard" ]
        [ View.Scoreboard.scoreboard game.scoreboard Scoreboard.Model.defaultModel Nothing ]
