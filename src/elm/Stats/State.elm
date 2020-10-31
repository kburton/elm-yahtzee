module Stats.State exposing (init, update)

import Dict
import Ports
import Scoreboard.Model as Scoreboard
import Stats.Model exposing (Model, defaultModel)
import Stats.Msg exposing (Msg(..))


init : Ports.HistoryModel -> ( Model, Cmd Msg )
init games =
    ( initStats games, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init games ->
            ( initStats games, Cmd.none )

        Update game ->
            ( updateHighScores game <| updateStats game model, Cmd.none )


cmpGames : Ports.GameModel -> Ports.GameModel -> Order
cmpGames a b =
    if a.g > b.g then
        GT

    else if a.g < b.g then
        LT

    else if a.t > b.t then
        LT

    else
        GT


getHighScoreGames : List Ports.GameModel -> List Ports.GameModel
getHighScoreGames games =
    List.take 10 <| List.reverse <| List.sortWith cmpGames games


initStats : Ports.HistoryModel -> Model
initStats games =
    let
        initModel =
            { defaultModel | highScoreGames = getHighScoreGames games }
    in
    List.foldl updateStats initModel games


updateStats : Ports.GameModel -> Model -> Model
updateStats game model =
    let
        scoreboard =
            Dict.fromList game.s

        grandTotal =
            game.g

        yahtzeeScored =
            (Maybe.withDefault 0 <| Scoreboard.getScore Scoreboard.Yahtzee scoreboard) > 0

        yahtzeeBonuses =
            Maybe.withDefault 0 <| Scoreboard.getScore Scoreboard.YahtzeeBonusCount scoreboard
    in
    { model
        | gamesPlayed = model.gamesPlayed + 1
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


updateHighScores : Ports.GameModel -> Model -> Model
updateHighScores game model =
    { model | highScoreGames = getHighScoreGames <| game :: model.highScoreGames }
