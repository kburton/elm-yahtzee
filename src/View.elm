module View exposing (view)

import Game.Dice
import Game.Scoreboard
import Game.Types
import Game.View
import Html exposing (Html, button, div, h1, h2, span, text)
import Html.Attributes exposing (disabled, style)
import Html.Events exposing (onClick)
import Types


view : Types.Model -> Html Types.Msg
view model =
    div
        []
        [ div
            [ style "float" "left" ]
            [ h1 [] [ text <| "Game " ++ String.fromInt (List.length model.game.games) ]
            , viewControls model
            , Html.map Types.GameMsg (Game.View.dice model.game)
            ]
        , Html.map Types.GameMsg (Game.View.scoreboard model.game)
        , viewMessage model
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


viewMessage : Types.Model -> Html Types.Msg
viewMessage model =
    let
        scoreboard =
            Game.Types.currentGame model.game
    in
    if Game.Dice.areRolling model.game.dice then
        text ""

    else if Game.Scoreboard.gameIsOver scoreboard then
        span
            []
            [ text <| "Game over! You scored " ++ String.fromInt (Game.Scoreboard.grandTotal scoreboard) ++ " points. "
            , button [ onClick (Types.GameMsg Game.Types.NewGame) ] [ text "Play again" ]
            ]

    else if model.game.roll == 1 then
        text "First roll"

    else if model.game.roll == 2 then
        text "Rolled once"

    else if model.game.roll == 3 then
        text "Rolled twice"

    else if Game.Types.maxRollsReached model.game then
        text "Choose a score slot"

    else
        text ""
