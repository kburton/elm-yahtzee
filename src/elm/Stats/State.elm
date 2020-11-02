module Stats.State exposing (init, update)

import Scoreboard.Model as Scoreboard
import Stats.Model exposing (Game, Model, defaultModel)
import Stats.Msg exposing (Msg(..))
import Time


init : List Game -> ( Model, Cmd Msg )
init games =
    ( initStats games, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init games ->
            ( initStats games, Cmd.none )

        Update game ->
            ( updateHighScores game <| updateStats game model, Cmd.none )


cmpGames : Game -> Game -> Order
cmpGames a b =
    if a.score > b.score then
        GT

    else if a.score < b.score then
        LT

    else if Time.posixToMillis a.timestamp > Time.posixToMillis b.timestamp then
        LT

    else
        GT


getHighScoreGames : List Game -> List Game
getHighScoreGames games =
    List.take 10 <| List.reverse <| List.sortWith cmpGames games


initStats : List Game -> Model
initStats games =
    let
        initModel =
            { defaultModel | highScoreGames = getHighScoreGames games }
    in
    List.foldl updateStats initModel games


updateStats : Game -> Model -> Model
updateStats game model =
    let
        yahtzeeScored =
            (Maybe.withDefault 0 <| Scoreboard.getScore Scoreboard.Yahtzee game.scoreboard) > 0

        yahtzeeBonuses =
            Maybe.withDefault 0 <| Scoreboard.getScore Scoreboard.YahtzeeBonusCount game.scoreboard
    in
    { model
        | gamesPlayed = model.gamesPlayed + 1
        , games200 =
            if game.score >= 200 then
                model.games200 + 1

            else
                model.games200
        , games300 =
            if game.score >= 300 then
                model.games300 + 1

            else
                model.games300
        , games400 =
            if game.score >= 400 then
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


updateHighScores : Game -> Model -> Model
updateHighScores game model =
    { model | highScoreGames = getHighScoreGames <| game :: model.highScoreGames }
