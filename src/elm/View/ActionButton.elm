module View.ActionButton exposing (actionButton)

import Dice.Model as Dice
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (Msg)
import Scoreboard.Model as Scoreboard
import Scoreboard.Summary


actionButton : Model -> Bool -> Html Msg
actionButton model isYahtzeeWildcard =
    div
        [ class "action-button", onClick <| action model ]
        (List.map (\line -> div [] [ text line ]) <| message model isYahtzeeWildcard)


action : Model -> Msg
action model =
    if Dice.anyRolling model.game.dice then
        Msg.NoOp

    else if Scoreboard.isComplete model.game.scoreboard then
        Msg.NewGame

    else if model.game.roll <= 3 then
        Msg.Roll

    else
        Msg.NoOp


message : Model -> Bool -> List String
message model isYahtzeeWildcard =
    if Dice.anyRolling model.game.dice then
        [ "" ]

    else if Scoreboard.isComplete model.game.scoreboard then
        let
            score =
                Scoreboard.Summary.grandTotal model.game.scoreboard

            highScore =
                case List.head model.stats.highScoreGames of
                    Just game ->
                        game.score

                    Nothing ->
                        0

            startText =
                if score >= highScore then
                    "New high score!"

                else
                    "Game over!"
        in
        [ startText ++ " You scored " ++ String.fromInt score ++ " points.", " Play again?" ]

    else if isYahtzeeWildcard && model.game.roll > 1 then
        [ "Yahtzee wildcard!" ]

    else if model.game.roll == 1 then
        if model.tutorialMode && Scoreboard.turn model.game.scoreboard == 1 then
            [ "Welcome to Elm Yahtzee!", "Tap here to roll the dice." ]

        else if model.tutorialMode && Scoreboard.turn model.game.scoreboard == 2 then
            [ "That’s it! Roll the dice to start your second turn.", "The game continues until all score slots are filled." ]

        else
            [ "First roll" ]

    else if model.game.roll == 2 then
        if model.tutorialMode && Scoreboard.turn model.game.scoreboard == 1 then
            [ "Look at the dice - which score will you go for?", "You can lock any dice by tapping them.", "Roll again when you’re ready." ]

        else if model.tutorialMode && Scoreboard.turn model.game.scoreboard == 2 then
            [ "You can tap the score slot name in the scoreboard for details about how the scoring works.", "Tap for your second roll." ]

        else
            [ "Second roll" ]

    else if model.game.roll == 3 then
        if model.tutorialMode && Scoreboard.turn model.game.scoreboard == 1 then
            [ "Did that roll help?", "You can still lock and unlock any dice.", "This is your last roll, make it count!" ]

        else if model.tutorialMode && Scoreboard.turn model.game.scoreboard == 2 then
            [ "This is your final roll." ]

        else
            [ "Final roll" ]

    else if model.game.roll > 3 then
        if model.tutorialMode && Scoreboard.turn model.game.scoreboard == 1 then
            [ "Tap a score slot to choose a score for this turn." ]

        else if model.tutorialMode && Scoreboard.turn model.game.scoreboard == 2 then
            [ "Okay, I think you can take it from here. Good luck!", "Choose the score slot for your second turn." ]

        else
            [ "Choose a score slot" ]

    else
        [ "" ]
