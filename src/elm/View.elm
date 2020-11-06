module View exposing (view)

import Browser
import Dice.Model as Dice
import Html exposing (Html, div, node, text)
import Html.Attributes exposing (class)
import Model exposing (ModalStack(..), Model)
import Msg exposing (Msg)
import Scoreboard.Model as Scoreboard
import Scoreboard.Score
import View.ActionButton
import View.Dice
import View.MenuBar
import View.Modal
import View.Scoreboard


aspectRatioBreakpoint : Float
aspectRatioBreakpoint =
    0.75


desktopAspectRatio : Float
desktopAspectRatio =
    0.6


view : Model -> Browser.Document Msg
view model =
    let
        modeClass =
            case mode model of
                Desktop ->
                    " container--desktop"

                Mobile ->
                    " container--mobile"

                Unknown ->
                    ""
    in
    { title = "Elm Yahtzee"
    , body =
        [ div
            [ class <| "container" ++ modeClass ]
            (htmlStyle model
                :: (case model.modalStack of
                        ModalStack (m :: _) ->
                            [ View.Modal.modal (m.modal model) ]

                        _ ->
                            View.MenuBar.menuBar :: game model
                   )
            )
        ]
    }


type ViewMode
    = Desktop
    | Mobile
    | Unknown


mode : Model -> ViewMode
mode model =
    case model.aspectRatio of
        Just aspectRatio ->
            if aspectRatio <= aspectRatioBreakpoint then
                Mobile

            else
                Desktop

        Nothing ->
            Unknown


htmlStyle : Model -> Html msg
htmlStyle model =
    node
        "style"
        []
        [ text <|
            case mode model of
                Mobile ->
                    "html { font-size: 1vw; }"

                Desktop ->
                    "html { font-size: " ++ String.fromFloat desktopAspectRatio ++ "vh; padding: 1vh; }"

                Unknown ->
                    "html { display: none; }"
        ]


game : Model -> List (Html Msg)
game model =
    let
        actionPaneClass =
            if model.tutorialMode then
                "action-pane action-pane--tutorial"

            else
                "action-pane"

        ( scoreOptions, isYahtzeeWildcard ) =
            if model.game.roll > 1 && not (Dice.anyRolling model.game.dice) then
                Scoreboard.Score.options (Dice.faces model.game.dice) model.game.scoreboard

            else
                ( Scoreboard.defaultModel, False )

        lastScoreKey =
            Maybe.map .lastScoreKey model.undo
    in
    [ div
        [ class "scoreboard-pane" ]
        [ View.Scoreboard.scoreboard model.game.scoreboard scoreOptions lastScoreKey ]
    , div
        [ class "dice-pane" ]
        (View.Dice.dice model.game.dice <| model.game.roll > 1)
    , div
        [ class actionPaneClass ]
        [ View.ActionButton.actionButton model isYahtzeeWildcard ]
    ]
