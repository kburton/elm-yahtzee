module Stats.State exposing (init, update)

import Dict
import Ports
import Scoreboard.Model as Scoreboard
import Stats.Model exposing (..)
import Stats.Msg exposing (..)


init : List Ports.GameModel -> ( Model, Cmd Msg )
init games =
    let
        model =
            List.foldl (\g m -> updateScoreboard m g.g <| Dict.fromList g.s) defaultModel games
    in
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update sb ->
            ( updateScoreboard model (Scoreboard.grandTotal sb) sb, Cmd.none )


updateScoreboard : Model -> Int -> Scoreboard.Model -> Model
updateScoreboard model grandTotal scoreboard =
    let
        yahtzeeScored =
            (Maybe.withDefault 0 <| Scoreboard.getScore Scoreboard.Yahtzee scoreboard) > 0

        yahtzeeBonuses =
            Maybe.withDefault 0 <| Scoreboard.getScore Scoreboard.YahtzeeBonusCount scoreboard
    in
    { model
        | gamesPlayed = model.gamesPlayed + 1
        , highScore =
            if grandTotal > model.highScore then
                grandTotal

            else
                model.highScore
        , games200 =
            if grandTotal >= 200 then
                model.games200 + 1

            else
                model.games200
        , games300 =
            if grandTotal >= 300 then
                model.games300 + 1

            else
                model.games300
        , games400 =
            if grandTotal >= 400 then
                model.games400 + 1

            else
                model.games400
        , yahtzees =
            if yahtzeeScored then
                model.yahtzees + 1

            else
                model.yahtzees
        , yahtzeeBonuses =
            model.yahtzeeBonuses + yahtzeeBonuses
    }
