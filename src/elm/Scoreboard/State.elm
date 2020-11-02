module Scoreboard.State exposing (init, update)

import Scoreboard.Model exposing (Model, ScoreKey(..), getScore, setScore)
import Scoreboard.Msg exposing (Msg(..))
import Scoreboard.Score
import Scoreboard.Summary


init : Model -> ( Model, Cmd Msg )
init persistedScoreboard =
    ( persistedScoreboard, Cmd.none )


update : Msg -> Model -> List Int -> ( Model, Cmd Msg )
update msg model dice =
    case msg of
        Score key ->
            let
                ( scoreOptions, _ ) =
                    Scoreboard.Score.options dice model

                isYahtzee =
                    (Maybe.withDefault 0 <| getScore Yahtzee scoreOptions) > 0

                yahtzeeAlreadyScored =
                    (Maybe.withDefault 0 <| getScore Yahtzee model) > 0

                score =
                    Maybe.withDefault 0 <| getScore key scoreOptions

                modelWithScore =
                    setScore key score model

                newModel =
                    if isYahtzee && yahtzeeAlreadyScored then
                        Scoreboard.Summary.incYahtzeeBonus modelWithScore

                    else
                        modelWithScore
            in
            ( newModel, Cmd.none )
