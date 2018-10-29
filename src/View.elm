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
            [ css Styles.mainPaneStyle ]
            [ div
                [ css Styles.wrapperPaneStyle ]
                [ div
                    [ css Styles.dicePaneStyle ]
                    [ div
                        [ css Styles.diceContainerStyle ]
                        (List.map (Html.Styled.map Types.GameMsg) (Game.View.dice model.game))
                    ]
                , div
                    [ css Styles.scoreboardPaneStyle ]
                    [ Html.Styled.map Types.GameMsg (Game.View.scoreboard model.game) ]
                ]
            ]
        , div
            [ css Styles.messagePaneStyle
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
        ( text "\u{00A0}", Types.NoOp )

    else if Game.Scoreboard.gameIsOver scoreboard then
        ( text <| "Game over! You scored " ++ String.fromInt (Game.Scoreboard.grandTotal scoreboard) ++ " points. Play again?"
        , Types.GameMsg Game.Types.NewGame
        )

    else if model.game.roll == 1 then
        ( text "First roll", Types.GameMsg Game.Types.Roll )

    else if model.game.roll == 2 then
        ( text "Second roll", Types.GameMsg Game.Types.Roll )

    else if model.game.roll == 3 then
        ( text "Final roll", Types.GameMsg Game.Types.Roll )

    else if Game.Types.maxRollsReached model.game then
        ( text "Choose a score slot", Types.NoOp )

    else
        ( text "\u{00A0}", Types.NoOp )
