module View exposing (view)

import Game.Types
import Game.View
import Html exposing (Html, button, div, h1, h2, text)
import Html.Attributes exposing (disabled, style)
import Html.Events exposing (onClick)
import Types


view : Types.Model -> Html Types.Msg
view model =
    div []
        [ h1 [] [ text <| "Game " ++ String.fromInt (List.length model.game.games) ]
        , viewTurns model
        , text (Game.View.rollDisplay model.game)
        , viewControls model
        , Html.map Types.GameMsg (Game.View.dice model.game)
        , Html.map Types.GameMsg (Game.View.scoreboard model.game)
        ]


viewControls : Types.Model -> Html Types.Msg
viewControls model =
    div [ style "margin-bottom" "1rem" ]
        [ button
            [ onClick (Types.GameMsg Game.Types.Roll)
            , disabled (Game.Types.maxRollsReached model.game)
            , style "font-size" "2rem"
            , style "margin-right" "1rem"
            ]
            [ text "Roll" ]
        ]


viewTurns : Types.Model -> Html Types.Msg
viewTurns model =
    if model.game.turn > Game.Types.maxTurns then
        div
            []
            [ h2 [] [ text "Game complete" ]
            , button [ onClick (Types.GameMsg Game.Types.NewGame) ] [ text "New Game" ]
            ]

    else
        h2 [] [ text <| "Turn " ++ String.fromInt model.game.turn ++ " of " ++ String.fromInt Game.Types.maxTurns ]
