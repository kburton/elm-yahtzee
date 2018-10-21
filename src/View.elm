module View exposing (view)

import Dice.Types
import Dice.View
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Types


view : Types.Model -> Html Types.Msg
view model =
    div []
        [ viewControls
        , Html.map Types.DiceMsg (Dice.View.dice model.dice)
        ]


viewControls : Html Types.Msg
viewControls =
    div [ style "margin-bottom" "1rem" ]
        [ button
            [ onClick (Types.DiceMsg Dice.Types.RollAll)
            , style "font-size" "2rem"
            , style "margin-right" "1rem"
            ]
            [ text "Roll all" ]
        ]
