module View.Modals.CompletedGame exposing (completedGame)

import Dict
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Modal.Model
import Model exposing (Model)
import Msg exposing (Msg)
import Ports
import Scoreboard.Model
import Time
import Utils.Date exposing (formatDate)
import View.Scoreboard


completedGame : Ports.GameModel -> Model -> Modal.Model.Model Msg
completedGame game model =
    { title = "Game Details"
    , body = Modal.Model.Raw <| div [ class "completed-game" ] [ summary game model, scoreboard game ]
    }


summary : Ports.GameModel -> Model -> Html Msg
summary game model =
    div
        [ class "completed-game__summary" ]
        [ div [] [ text <| formatDate model.timeZone <| Time.millisToPosix game.t ]
        , div [] [ text <| String.fromInt game.g ++ " points" ]
        ]


scoreboard : Ports.GameModel -> Html Msg
scoreboard game =
    div
        [ class "completed-game__scoreboard" ]
        [ View.Scoreboard.scoreboard (Dict.fromList game.s) Scoreboard.Model.defaultModel Nothing ]
