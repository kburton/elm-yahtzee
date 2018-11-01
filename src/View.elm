module View exposing (view)

import Game.Dice
import Game.Scoreboard
import Game.Types
import Game.View
import Html
import Html.Styled exposing (Html, button, div, h1, h2, span, text)
import Html.Styled.Attributes exposing (css, disabled, style)
import Html.Styled.Events exposing (onClick)
import Styles
import Types


view : Types.Model -> Html Types.Msg
view model =
    let
        ( messageHtml, messageAction ) =
            viewMessage model
    in
    div
        [ css Styles.containerStyle ]
        [ div
            [ css Styles.scoreboardPaneStyle ]
            [ Html.Styled.map Types.GameMsg (Game.View.scoreboard model.game) ]
        , div
            [ css Styles.dicePaneStyle ]
            (List.map (Html.Styled.map Types.GameMsg) (Game.View.dice model.game))
        , div
            [ css <| Styles.messagePaneStyle model.game.tutorialMode
            , onClick messageAction
            ]
            [ messageHtml ]
        ]


viewControls : Types.Model -> Html Types.Msg
viewControls model =
    div
        [ style "margin-bottom" "1rem" ]
        [ button
            [ onClick (Types.GameMsg Game.Types.Roll)
            , disabled (Game.Types.maxRollsReached model.game)
            , style "font-size" "2rem"
            , style "margin-right" "1rem"
            ]
            [ text "Roll" ]
        ]


viewMessage : Types.Model -> ( Html msg, Types.Msg )
viewMessage model =
    let
        scoreboard =
            Game.Types.currentGame model.game
    in
    if Game.Dice.areRolling model.game.dice then
        ( text "", Types.NoOp )

    else if Game.Scoreboard.gameIsOver scoreboard then
        ( textToDivs [ "Game over! You scored " ++ String.fromInt (Game.Scoreboard.grandTotal scoreboard) ++ " points.", " Play again?" ]
        , Types.GameMsg Game.Types.NewGame
        )

    else if model.game.roll == 1 then
        if model.game.tutorialMode && model.game.turn == 1 then
            ( textToDivs
                [ "Welcome to Elm Yahtzee!", "Tap here to roll the dice." ]
            , Types.GameMsg Game.Types.Roll
            )

        else if model.game.tutorialMode && model.game.turn == 2 then
            ( textToDivs
                [ "That’s it! Roll the dice to start your second turn.", "The game continues until all score slots are filled." ]
            , Types.GameMsg Game.Types.Roll
            )

        else
            ( text "First roll", Types.GameMsg Game.Types.Roll )

    else if model.game.roll == 2 then
        if model.game.tutorialMode && model.game.turn == 1 then
            ( textToDivs
                [ "Look at the dice - which score will you aim for?", "You can lock any dice by tapping them.", "Roll again when you’re ready." ]
            , Types.GameMsg Game.Types.Roll
            )

        else if model.game.tutorialMode && model.game.turn == 2 then
            ( textToDivs
                [ "You can tap the score slot name in the scoreboard for details about how the scoring works.", "Tap for your second roll." ]
            , Types.GameMsg Game.Types.Roll
            )

        else
            ( text "Second roll", Types.GameMsg Game.Types.Roll )

    else if model.game.roll == 3 then
        if model.game.tutorialMode && model.game.turn == 1 then
            ( textToDivs
                [ "Did that roll help?", "You can still lock and unlock any dice.", "This is your last roll, make it count!" ]
            , Types.GameMsg Game.Types.Roll
            )

        else if model.game.tutorialMode && model.game.turn == 2 then
            ( textToDivs
                [ "This is your final roll." ]
            , Types.GameMsg Game.Types.Roll
            )

        else
            ( text "Final roll", Types.GameMsg Game.Types.Roll )

    else if Game.Types.maxRollsReached model.game then
        if model.game.tutorialMode && model.game.turn == 1 then
            ( text "Tap a score slot to choose a score for this turn.", Types.NoOp )

        else if model.game.tutorialMode && model.game.turn == 2 then
            ( textToDivs
                [ "Okay, I think you can take it from here. Good luck!", "Choose the score slot for your second turn." ]
            , Types.NoOp
            )

        else
            ( text "Choose a score slot", Types.NoOp )

    else
        ( text "", Types.NoOp )


textToDivs : List String -> Html msg
textToDivs =
    div [] << List.map (\line -> div [] [ text line ])
