module View exposing (view)

import Dice.Model as Dice
import Html exposing (Html, button, div, h1, h2, node, span, text)
import Html.Attributes exposing (class, disabled, style)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (Msg)
import Scoreboard.Model as Scoreboard
import Scoreboard.Score
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt
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
        messagePaneClass =
            if model.tutorialMode then
                "message-pane message-pane--tutorial"

            else
                "message-pane"

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
        [ class messagePaneClass
        , onClick <| messageAction model
        ]
        [ messageHtml model isYahtzeeWildcard ]
    ]


messageHtml : Model -> Bool -> Html msg
messageHtml model isYahtzeeWildcard =
    if Dice.anyRolling model.dice then
        text ""

    else if Scoreboard.isComplete model.scoreboard then
        let
            score =
                Scoreboard.grandTotal model.scoreboard

            startText =
                if model.gamesPlayed > 1 && score == model.highScore then
                    "New high score!"

                else
                    "Game over!"
        in
        textToDivs [ startText ++ " You scored " ++ String.fromInt score ++ " points.", " Play again?" ]

    else if isYahtzeeWildcard && model.roll > 1 then
        text "Yahtzee wildcard!"

    else if model.roll == 1 then
        if model.tutorialMode && Scoreboard.turn model.scoreboard == 1 then
            textToDivs [ "Welcome to Elm Yahtzee!", "Tap here to roll the dice." ]

        else if model.tutorialMode && Scoreboard.turn model.scoreboard == 2 then
            textToDivs [ "That’s it! Roll the dice to start your second turn.", "The game continues until all score slots are filled." ]

        else
            text "First roll"

    else if model.roll == 2 then
        if model.tutorialMode && Scoreboard.turn model.scoreboard == 1 then
            textToDivs [ "Look at the dice - which score will you go for?", "You can lock any dice by tapping them.", "Roll again when you’re ready." ]

        else if model.tutorialMode && Scoreboard.turn model.scoreboard == 2 then
            textToDivs [ "You can tap the score slot name in the scoreboard for details about how the scoring works.", "Tap for your second roll." ]

        else
            text "Second roll"

    else if model.roll == 3 then
        if model.tutorialMode && Scoreboard.turn model.scoreboard == 1 then
            textToDivs [ "Did that roll help?", "You can still lock and unlock any dice.", "This is your last roll, make it count!" ]

        else if model.tutorialMode && Scoreboard.turn model.scoreboard == 2 then
            textToDivs [ "This is your final roll." ]

        else
            text "Final roll"

    else if model.roll > 3 then
        if model.tutorialMode && Scoreboard.turn model.scoreboard == 1 then
            text "Tap a score slot to choose a score for this turn."

        else if model.tutorialMode && Scoreboard.turn model.scoreboard == 2 then
            textToDivs [ "Okay, I think you can take it from here. Good luck!", "Choose the score slot for your second turn." ]

        else
            text "Choose a score slot"

    else
        text ""


messageAction : Model -> Msg
messageAction model =
    if Dice.anyRolling model.dice then
        Msg.NoOp

    else if Scoreboard.isComplete model.scoreboard then
        Msg.NewGame

    else if model.roll <= 3 then
        Msg.Roll

    else
        Msg.NoOp


textToDivs : List String -> Html msg
textToDivs =
    div [] << List.map (\line -> div [] [ text line ])
