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
import Svg.Styled as Svg
import Svg.Styled.Attributes as SvgAtt
import Svg.Styled.Events as SvgEvt
import Types


view : Types.Model -> Html Types.Msg
view model =
    div
        [ css Styles.containerStyle ]
        ([ Styles.globalStyle
         , menuBar
            (if model.menuOpen then
                "Menu"

             else
                "Elm Yahtzee"
            )
         ]
            ++ (if model.menuOpen then
                    [ menu ]

                else
                    [ div
                        [ css Styles.scoreboardPaneStyle ]
                        [ Html.Styled.map Types.GameMsg (Game.View.scoreboard model.game) ]
                    , div
                        [ css Styles.dicePaneStyle ]
                        (List.map (Html.Styled.map Types.GameMsg) (Game.View.dice model.game))
                    , div
                        [ css <| Styles.messagePaneStyle model.game.tutorialMode
                        , onClick <| messageAction model
                        ]
                        [ messageHtml model ]
                    ]
               )
        )


menuBar : String -> Html Types.Msg
menuBar title =
    div
        [ css Styles.menuBarStyle ]
        [ text title
        , menuButton
        ]


menuButton : Html Types.Msg
menuButton =
    Svg.svg
        [ SvgAtt.viewBox "0 0 32 24"
        , SvgAtt.style "fill: currentColor; height: 100%;"
        , SvgEvt.onClick Types.ToggleMenu
        ]
        [ Svg.rect
            [ SvgAtt.x "0"
            , SvgAtt.y "0"
            , SvgAtt.width "32"
            , SvgAtt.height "4"
            , SvgAtt.rx "2"
            , SvgAtt.ry "2"
            ]
            []
        , Svg.rect
            [ SvgAtt.x "0"
            , SvgAtt.y "10"
            , SvgAtt.width "32"
            , SvgAtt.height "4"
            , SvgAtt.rx "2"
            , SvgAtt.ry "2"
            ]
            []
        , Svg.rect
            [ SvgAtt.x "0"
            , SvgAtt.y "20"
            , SvgAtt.width "32"
            , SvgAtt.height "4"
            , SvgAtt.rx "2"
            , SvgAtt.ry "2"
            ]
            []
        ]


menu : Html Types.Msg
menu =
    div [] []


messageHtml : Types.Model -> Html msg
messageHtml model =
    let
        scoreboard =
            Game.Types.currentGame model.game
    in
    if Game.Dice.areRolling model.game.dice then
        text ""

    else if Game.Scoreboard.gameIsOver scoreboard then
        textToDivs [ "Game over! You scored " ++ String.fromInt (Game.Scoreboard.grandTotal scoreboard) ++ " points.", " Play again?" ]

    else if Game.Dice.isYahtzeeWildcard model.game.dice scoreboard && model.game.roll > 1 then
        text "Yahtzee wildcard!"

    else if model.game.roll == 1 then
        if model.game.tutorialMode && model.game.turn == 1 then
            textToDivs [ "Welcome to Elm Yahtzee!", "Tap here to roll the dice." ]

        else if model.game.tutorialMode && model.game.turn == 2 then
            textToDivs [ "That’s it! Roll the dice to start your second turn.", "The game continues until all score slots are filled." ]

        else
            text "First roll"

    else if model.game.roll == 2 then
        if model.game.tutorialMode && model.game.turn == 1 then
            textToDivs [ "Look at the dice - which score will you aim for?", "You can lock any dice by tapping them.", "Roll again when you’re ready." ]

        else if model.game.tutorialMode && model.game.turn == 2 then
            textToDivs [ "You can tap the score slot name in the scoreboard for details about how the scoring works.", "Tap for your second roll." ]

        else
            text "Second roll"

    else if model.game.roll == 3 then
        if model.game.tutorialMode && model.game.turn == 1 then
            textToDivs [ "Did that roll help?", "You can still lock and unlock any dice.", "This is your last roll, make it count!" ]

        else if model.game.tutorialMode && model.game.turn == 2 then
            textToDivs [ "This is your final roll." ]

        else
            text "Final roll"

    else if Game.Types.maxRollsReached model.game then
        if model.game.tutorialMode && model.game.turn == 1 then
            text "Tap a score slot to choose a score for this turn."

        else if model.game.tutorialMode && model.game.turn == 2 then
            textToDivs [ "Okay, I think you can take it from here. Good luck!", "Choose the score slot for your second turn." ]

        else
            text "Choose a score slot"

    else
        text ""


messageAction : Types.Model -> Types.Msg
messageAction model =
    let
        scoreboard =
            Game.Types.currentGame model.game
    in
    if Game.Dice.areRolling model.game.dice then
        Types.NoOp

    else if Game.Scoreboard.gameIsOver scoreboard then
        Types.GameMsg Game.Types.NewGame

    else if not <| Game.Types.maxRollsReached model.game then
        Types.GameMsg Game.Types.Roll

    else
        Types.NoOp


overridableHtml : Html msg -> Maybe (Html msg) -> Html msg
overridableHtml html override =
    case override of
        Nothing ->
            html

        Just ovr ->
            ovr


textToDivs : List String -> Html msg
textToDivs =
    div [] << List.map (\line -> div [] [ text line ])
