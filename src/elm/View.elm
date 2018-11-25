module View exposing (view)

import Dice.Model as Dice
import Html exposing (Html, div, node, text)
import Html.Attributes exposing (class)
import Model exposing (Model)
import Msg exposing (Msg)
import Scoreboard.Model as Scoreboard
import Scoreboard.Score
import View.ActionButton
import View.Dice
import View.Menu
import View.MenuBar
import View.Modal
import View.Scoreboard


aspectRatioBreakpoint =
    0.75


desktopAspectRatio =
    0.6


view : Model -> Html Msg
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
    div
        [ class <| "container" ++ modeClass ]
        ([ htmlStyle model ]
            ++ (case model.modalStack of
                    m :: rest ->
                        [ View.Modal.modal m ]

                    _ ->
                        menuGameWrapper model
               )
        )


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


menuGameWrapper : Model -> List (Html Msg)
menuGameWrapper model =
    [ View.MenuBar.menuBar model.menuOpen ]
        ++ (if model.menuOpen then
                [ View.Menu.menu ]

            else
                game model
           )


game : Model -> List (Html Msg)
game model =
    let
        actionPaneClass =
            if model.tutorialMode then
                "action-pane action-pane--tutorial"

            else
                "action-pane"

        ( scoreOptions, isYahtzeeWildcard ) =
            if model.roll > 1 && not (Dice.anyRolling model.dice) then
                Scoreboard.Score.options (Dice.faces model.dice) model.scoreboard

            else
                ( Scoreboard.defaultModel, False )

        lastScoreKey =
            case model.undo of
                Just u ->
                    Just u.lastScoreKey

                Nothing ->
                    Nothing
    in
    [ div
        [ class "scoreboard-pane" ]
        [ View.Scoreboard.scoreboard model.scoreboard scoreOptions lastScoreKey ]
    , div
        [ class "dice-pane" ]
        (View.Dice.dice model.dice <| model.roll > 1)
    , div
        [ class actionPaneClass ]
        [ View.ActionButton.actionButton model isYahtzeeWildcard ]
    ]
