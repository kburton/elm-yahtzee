module View.Scoreboard exposing (scoreboard)

import Help.Model as Help
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Msg exposing (Msg)
import Scoreboard.Model exposing (Model, ScoreKey(..), getScore)
import Scoreboard.Summary as Summary
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt


scoreboard : Model -> Model -> Maybe ScoreKey -> Html Msg
scoreboard model scoreOptions lastScoreKey =
    let
        buildRow : ScoreKey -> Help.HelpKey -> String -> String -> Html Msg
        buildRow scoreKey helpKey label info =
            row scoreKey helpKey label info model scoreOptions (lastScoreKey == Just scoreKey)

        buildBonusRow : ScoreKey -> Help.HelpKey -> Help.HelpKey -> String -> String -> Int -> Html Msg
        buildBonusRow scoreKey helpKey bonusHelpKey label info bonus =
            bonusRow scoreKey helpKey bonusHelpKey label info bonus model scoreOptions (lastScoreKey == Just scoreKey)
    in
    div
        [ class "scoreboard" ]
        [ buildRow Ones Help.ScoreOnes "Aces" "Sum of ones"
        , buildRow Twos Help.ScoreTwos "Twos" "Sum of twos"
        , buildRow Threes Help.ScoreThrees "Threes" "Sum of threes"
        , buildRow Fours Help.ScoreFours "Fours" "Sum of fours"
        , buildRow Fives Help.ScoreFives "Fives" "Sum of fives"
        , buildBonusRow Sixes Help.ScoreSixes Help.BonusUpper "Sixes" "Sum of sixes" <| Summary.upperBonus model
        , divider
        , buildRow ThreeOfKind Help.ScoreThreeOfKind "3 of a kind" "Sum of all dice"
        , buildRow FourOfKind Help.ScoreFourOfKind "4 of a kind" "Sum of all dice"
        , buildRow FullHouse Help.ScoreFullHouse "Full house" "25 points"
        , buildRow SmallStraight Help.ScoreSmallStraight "Sm straight" "30 points"
        , buildRow LargeStraight Help.ScoreLargeStraight "Lg straight" "40 points"
        , buildBonusRow Yahtzee Help.ScoreYahtzee Help.BonusYahtzee "Yahtzee" "50 points" <| Summary.yahtzeeBonus model
        , buildRow Chance Help.ScoreChance "Chance" "Sum of all dice"
        ]


row : ScoreKey -> Help.HelpKey -> String -> String -> Model -> Model -> Bool -> Html Msg
row scoreKey helpKey label info model scoreOptions showUndo =
    div
        [ class "scoreboard__row" ]
        [ scoreLabel helpKey label
        , scoreInfo helpKey info
        , scoreValue scoreKey model scoreOptions showUndo
        ]


bonusRow : ScoreKey -> Help.HelpKey -> Help.HelpKey -> String -> String -> Int -> Model -> Model -> Bool -> Html Msg
bonusRow scoreKey helpKey bonusHelpKey label info bonus model scoreOptions showUndo =
    if bonus == 0 then
        row scoreKey helpKey label info model scoreOptions showUndo

    else
        div
            [ class "scoreboard__row" ]
            [ scoreLabel helpKey label
            , scoreBonus bonusHelpKey bonus
            , scoreValue scoreKey model scoreOptions showUndo
            ]


divider : Html msg
divider =
    div [ class "scoreboard__divider" ] []


scoreLabel : Help.HelpKey -> String -> Html Msg
scoreLabel helpKey label =
    div [ class "scoreboard__label", onClick <| Msg.ShowHelp helpKey ] [ text label ]


scoreInfo : Help.HelpKey -> String -> Html Msg
scoreInfo helpKey info =
    div [ class "scoreboard__info", onClick <| Msg.ShowHelp helpKey ] [ text info ]


scoreBonus : Help.HelpKey -> Int -> Html Msg
scoreBonus bonusHelpKey bonus =
    div [ class "scoreboard__bonus", onClick <| Msg.ShowHelp bonusHelpKey ] [ text <| "Bonus " ++ String.fromInt bonus ]


scoreValue : ScoreKey -> Model -> Model -> Bool -> Html Msg
scoreValue scoreKey model scoreOptions showUndo =
    case getScore scoreKey model of
        Nothing ->
            case getScore scoreKey scoreOptions of
                Just s ->
                    div
                        [ class "scoreboard__value scoreboard__value--clickable"
                        , onClick <| Msg.Score scoreKey
                        ]
                        [ div [ class "scoreboard__value-text" ] [ text <| String.fromInt s ] ]

                Nothing ->
                    div
                        [ class "scoreboard__value" ]
                        [ text "\u{00A0}" ]

        Just s ->
            div
                [ class "scoreboard__value" ]
                ([ div [ class "scoreboard__value-text" ] [ text <| String.fromInt s ]
                 ]
                    ++ (if showUndo then
                            [ undo ]

                        else
                            []
                       )
                )


undo : Html Msg
undo =
    div [ class "scoreboard__undo" ] [ undoSvg ]


undoSvg : Html Msg
undoSvg =
    Svg.svg
        [ SvgAtt.viewBox "0 0 24 24"
        , SvgAtt.class "scoreboard__undo-icon"
        , SvgEvt.onClick Msg.Undo
        ]
        [ Svg.path
            [ SvgAtt.d "M18.885 3.515c-4.617-4.618-12.056-4.676-16.756-.195l-2.129-2.258v7.938h7.484l-2.066-2.191c2.82-2.706 7.297-2.676 10.073.1 4.341 4.341 1.737 12.291-5.491 12.291v4.8c3.708 0 6.614-1.244 8.885-3.515 4.686-4.686 4.686-12.284 0-16.97z" ]
            []
        ]
