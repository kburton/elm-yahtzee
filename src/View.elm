module View exposing (view)

import Game.Dice
import Game.Scoreboard
import Game.Types
import Game.View
import Html exposing (Html, button, div, h1, h2, node, span, text)
import Html.Attributes exposing (class, disabled, style)
import Html.Events exposing (onClick)
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt
import Types


view : Types.Model -> Html Types.Msg
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
            ++ (case model.modal of
                    Just ( header, content ) ->
                        modal header content

                    Nothing ->
                        menuGameWrapper model
               )
        )


type ViewMode
    = Desktop
    | Mobile
    | Unknown


aspectRatioBreakpoint =
    0.7


mode : Types.Model -> ViewMode
mode model =
    case model.aspectRatio of
        Just aspectRatio ->
            if aspectRatio <= aspectRatioBreakpoint then
                Mobile

            else
                Desktop

        Nothing ->
            Unknown


htmlStyle : Types.Model -> Html msg
htmlStyle model =
    node
        "style"
        []
        [ text <|
            case mode model of
                Mobile ->
                    "html { font-size: 1vw; }"

                Desktop ->
                    "html { font-size: 0.6vh; padding: 1vh; }"

                Unknown ->
                    "html { display: none; }"
        ]


menuGameWrapper : Types.Model -> List (Html Types.Msg)
menuGameWrapper model =
    [ menuBar
        (if model.menuOpen then
            "Menu"

         else
            "Elm Yahtzee"
        )
    ]
        ++ (if model.menuOpen then
                [ menu ]

            else
                game model
           )


game : Types.Model -> List (Html Types.Msg)
game model =
    let
        messagePaneClass =
            if model.game.tutorialMode then
                "message-pane message-pane--tutorial"

            else
                "message-pane"
    in
    [ div
        [ class "scoreboard-pane" ]
        [ Html.map Types.GameMsg (Game.View.scoreboard model.game) ]
    , div
        [ class "dice-pane" ]
        (List.map (Html.map Types.GameMsg) (Game.View.dice model.game))
    , div
        [ class messagePaneClass
        , onClick <| messageAction model
        ]
        [ messageHtml model ]
    ]


menuBar : String -> Html Types.Msg
menuBar title =
    div
        [ class "menu-bar" ]
        [ text title
        , menuButton
        ]


menuButton : Html Types.Msg
menuButton =
    Svg.svg
        [ SvgAtt.viewBox "0 0 32 24"
        , SvgAtt.class "menu-button"
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
    div [ class "menu" ] []


modal : String -> List ( String, Html Types.Msg ) -> List (Html Types.Msg)
modal header sections =
    [ div
        [ class "modal__header" ]
        [ div [] [ text header ]
        , modalCloseButton
        ]
    , div
        [ class "modal__body" ]
        (List.map
            (\( h, c ) ->
                div
                    [ class "modal__section" ]
                    [ div [ class "modal__section-header" ] [ text h ]
                    , div [] [ c ]
                    ]
            )
            sections
        )
    ]


modalCloseButton : Html Types.Msg
modalCloseButton =
    Svg.svg
        [ SvgAtt.viewBox "0 0 12 12"
        , SvgAtt.class "modal__close"
        , SvgEvt.onClick Types.CloseModal
        ]
        [ Svg.line [ SvgAtt.x1 "1", SvgAtt.y1 "11", SvgAtt.x2 "11", SvgAtt.y2 "1", SvgAtt.strokeWidth "2", SvgAtt.strokeLinecap "round" ] []
        , Svg.line [ SvgAtt.x1 "1", SvgAtt.y1 "1", SvgAtt.x2 "11", SvgAtt.y2 "11", SvgAtt.strokeWidth "2", SvgAtt.strokeLinecap "round" ] []
        ]


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
            textToDivs [ "Look at the dice - which score will you go for?", "You can lock any dice by tapping them.", "Roll again when you’re ready." ]

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
