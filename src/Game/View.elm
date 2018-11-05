module Game.View exposing (dice, scoreboard)

import Array
import Game.Dice as Dice
import Game.Scoreboard as Scoreboard
import Game.Types as Types
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Svg
import Svg.Attributes as SvgAtt
import Svg.Events as SvgEvt


scoreboard : Types.Model -> Html Types.Msg
scoreboard model =
    div
        [ class "scoreboard" ]
        [ scoreboardRow model Types.Ones "Aces" "Sum of ones"
        , scoreboardRow model Types.Twos "Twos" "Sum of twos"
        , scoreboardRow model Types.Threes "Threes" "Sum of threes"
        , scoreboardRow model Types.Fours "Fours" "Sum of fours"
        , scoreboardRow model Types.Fives "Fives" "Sum of fives"
        , scoreboardBonusRow model Types.Sixes Types.UpperSectionBonus Scoreboard.upperBonus "Sixes" "Sum of sixes"
        , scoreboardDivider
        , scoreboardRow model Types.ThreeOfKind "3 of a kind" "Sum of all dice"
        , scoreboardRow model Types.FourOfKind "4 of a kind" "Sum of all dice"
        , scoreboardRow model Types.FullHouse "Full house" "25 points"
        , scoreboardRow model Types.SmallStraight "Sm straight" "30 points"
        , scoreboardRow model Types.LargeStraight "Lg straight" "40 points"
        , scoreboardBonusRow model Types.Yahtzee Types.YahtzeeBonus Scoreboard.yahtzeeBonus "Yahtzee" "50 points"
        , scoreboardRow model Types.Chance "Chance" "Sum of all dice"
        ]


scoreboardRow : Types.Model -> Types.ScoreKey -> String -> String -> Html Types.Msg
scoreboardRow model key label info =
    case model.games of
        game :: rest ->
            div
                [ class "scoreboard__row" ]
                [ scoreLabel key label
                , scoreInfo key info
                , scoreValue model key game
                ]

        _ ->
            div [] []


scoreboardBonusRow : Types.Model -> Types.ScoreKey -> Types.Bonus -> (Types.Scoreboard -> Int) -> String -> String -> Html Types.Msg
scoreboardBonusRow model key bonusType bonusFn label info =
    case model.games of
        game :: rest ->
            let
                bonus =
                    bonusFn game
            in
            if bonus == 0 then
                scoreboardRow model key label info

            else
                div
                    [ class "scoreboard__row" ]
                    [ scoreLabel key label
                    , scoreBonus bonusType bonus
                    , scoreValue model key game
                    ]

        _ ->
            div [] []


scoreboardDivider : Html msg
scoreboardDivider =
    div [ class "scoreboard__divider" ] []


scoreLabel : Types.ScoreKey -> String -> Html Types.Msg
scoreLabel key label =
    let
        ( helpHeader, helpContent ) =
            help key
    in
    div [ class "scoreboard__label", onClick <| Types.ShowHelp helpHeader helpContent ] [ text label ]


scoreInfo : Types.ScoreKey -> String -> Html Types.Msg
scoreInfo key info =
    let
        ( helpHeader, helpContent ) =
            help key
    in
    div [ class "scoreboard__info", onClick <| Types.ShowHelp helpHeader helpContent ] [ text info ]


scoreBonus : Types.Bonus -> Int -> Html Types.Msg
scoreBonus bonusType bonus =
    let
        ( helpHeader, helpContent ) =
            helpBonuses bonusType
    in
    div
        [ class "scoreboard__bonus", onClick <| Types.ShowHelp helpHeader helpContent ]
        [ text <| "Bonus " ++ String.fromInt bonus ]


scoreValue : Types.Model -> Types.ScoreKey -> Types.Scoreboard -> Html Types.Msg
scoreValue model key game =
    case Scoreboard.getScore key game of
        Nothing ->
            if not (Dice.areRolling model.dice) && model.roll > 1 then
                div
                    [ class "scoreboard__value scoreboard__value--clickable", onClick (Types.Score key) ]
                    [ text <| String.fromInt <| Dice.calcScore key model.dice game ]

            else
                div
                    [ class "scoreboard__value" ]
                    [ text "\u{00A0}" ]

        Just n ->
            div
                [ class "scoreboard__value" ]
                ([ div [] [ text <| String.fromInt n ]
                 ]
                    ++ (case scoreUndo model key of
                            Just html ->
                                [ html ]

                            Nothing ->
                                []
                       )
                )


scoreUndo : Types.Model -> Types.ScoreKey -> Maybe (Html Types.Msg)
scoreUndo model key =
    case ( model.lastScoreKey, model.previous ) of
        ( Just k, Just (Types.Previous p) ) ->
            if k == key && (not <| Scoreboard.gameIsOver <| Types.currentGame model) then
                Just (div [ class "scoreboard__undo" ] [ undoSvg ])

            else
                Nothing

        _ ->
            Nothing


undoSvg : Html Types.Msg
undoSvg =
    Svg.svg
        [ SvgAtt.viewBox "0 0 24 24"
        , SvgAtt.class "scoreboard__undo-icon"
        , SvgEvt.onClick Types.Undo
        ]
        [ Svg.path
            [ SvgAtt.d "M18.885 3.515c-4.617-4.618-12.056-4.676-16.756-.195l-2.129-2.258v7.938h7.484l-2.066-2.191c2.82-2.706 7.297-2.676 10.073.1 4.341 4.341 1.737 12.291-5.491 12.291v4.8c3.708 0 6.614-1.244 8.885-3.515 4.686-4.686 4.686-12.284 0-16.97z" ]
            []
        ]


dice : Types.Model -> List (Html Types.Msg)
dice model =
    Array.toList <| Array.indexedMap clickableDie model.dice


type DieType
    = DieTypeLocked
    | DieTypeUnlocked
    | DieTypeExample
    | DieTypeExampleScored


clickableDie : Types.Index -> Types.Die -> Html Types.Msg
clickableDie index dieModel =
    let
        dieType =
            if dieModel.locked then
                DieTypeLocked

            else
                DieTypeUnlocked
    in
    die dieType dieModel.face (Just (Types.ToggleLock index))


exampleDice : List ( Types.Face, Bool ) -> List (Html Types.Msg)
exampleDice faces =
    List.map (\( f, s ) -> exampleDie f s) faces


exampleDie : Types.Face -> Bool -> Html Types.Msg
exampleDie face isScoring =
    let
        dieType =
            if isScoring then
                DieTypeExampleScored

            else
                DieTypeExample
    in
    die dieType face Nothing


die : DieType -> Types.Face -> Maybe Types.Msg -> Html Types.Msg
die dieType face msg =
    let
        ( evt, baseClass ) =
            case msg of
                Just m ->
                    ( [ SvgEvt.onClick m ], "die die--clickable" )

                Nothing ->
                    ( [], "die" )

        typeClass =
            case dieType of
                DieTypeLocked ->
                    "die--locked"

                DieTypeUnlocked ->
                    "die--unlocked"

                DieTypeExample ->
                    "die--example"

                DieTypeExampleScored ->
                    "die--example-scored"

        class =
            baseClass ++ " " ++ typeClass
    in
    Svg.svg
        ([ SvgAtt.viewBox "0 0 120 120", SvgAtt.class class ] ++ evt)
        (dieFace ++ spots face)


dieFace : List (Svg.Svg msg)
dieFace =
    [ Svg.rect
        [ SvgAtt.x "0"
        , SvgAtt.y "0"
        , SvgAtt.width "120"
        , SvgAtt.height "120"
        , SvgAtt.rx "25"
        , SvgAtt.ry "25"
        ]
        []
    ]


spots : Types.Face -> List (Svg.Svg msg)
spots face =
    let
        smSpot =
            spot "12"

        mdSpot =
            spot "15"

        lgSpot =
            spot "20"
    in
    case face of
        1 ->
            [ lgSpot M C ]

        2 ->
            [ mdSpot T L, mdSpot B R ]

        3 ->
            [ mdSpot T L, mdSpot M C, mdSpot B R ]

        4 ->
            [ mdSpot T L, mdSpot T R, mdSpot B L, mdSpot B R ]

        5 ->
            [ mdSpot T L, mdSpot T R, mdSpot M C, mdSpot B L, mdSpot B R ]

        6 ->
            [ smSpot T L, smSpot T R, smSpot M L, smSpot M R, smSpot B L, smSpot B R ]

        _ ->
            []


type DieV
    = T
    | M
    | B


type DieH
    = L
    | C
    | R


spot : String -> DieV -> DieH -> Html msg
spot r v h =
    let
        x =
            case h of
                L ->
                    "30"

                C ->
                    "60"

                R ->
                    "90"

        y =
            case v of
                T ->
                    "30"

                M ->
                    "60"

                B ->
                    "90"
    in
    Svg.circle
        [ SvgAtt.cx x
        , SvgAtt.cy y
        , SvgAtt.r r
        , SvgAtt.class "die__spot"
        , SvgAtt.pointerEvents "none"
        ]
        []


helpBonuses : Types.Bonus -> ( String, List ( String, Html Types.Msg ) )
helpBonuses bonusType =
    case bonusType of
        Types.UpperSectionBonus ->
            ( "Help | Upper section bonus"
            , [ ( "Upper section bonus"
                , helpUpperSectionBonusContent
                )
              ]
            )

        Types.YahtzeeBonus ->
            ( "Help | Yahtzee bonus"
            , [ ( "Yahtzee bonus"
                , helpYahtzeeBonusContent
                )
              ]
            )


help : Types.ScoreKey -> ( String, List ( String, Html Types.Msg ) )
help key =
    let
        t =
            True

        f =
            False
    in
    case key of
        Types.Ones ->
            helpEntry
                "Aces"
                (text "Score the sum of ones.")
                [ ( [ ( 1, t ), ( 2, f ), ( 3, f ), ( 4, f ), ( 5, f ) ], 1 )
                , ( [ ( 1, t ), ( 1, t ), ( 1, t ), ( 4, f ), ( 5, f ) ], 3 )
                , ( [ ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ) ], 5 )
                , ( [ ( 2, f ), ( 3, f ), ( 4, f ), ( 5, f ), ( 6, f ) ], 0 )
                ]
                [ helpUpperSectionBonus ]

        Types.Twos ->
            helpEntry
                "Twos"
                (text "Score the sum of twos.")
                [ ( [ ( 1, f ), ( 2, t ), ( 3, f ), ( 4, f ), ( 5, f ) ], 2 )
                , ( [ ( 2, t ), ( 2, t ), ( 3, f ), ( 4, f ), ( 5, f ) ], 4 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 10 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ) ], 0 )
                ]
                [ helpUpperSectionBonus ]

        Types.Threes ->
            helpEntry
                "Threes"
                (text "Score the sum of threes.")
                [ ( [ ( 1, f ), ( 2, f ), ( 3, t ), ( 4, f ), ( 5, f ) ], 3 )
                , ( [ ( 3, t ), ( 3, t ), ( 3, t ), ( 4, f ), ( 5, f ) ], 9 )
                , ( [ ( 3, t ), ( 3, t ), ( 3, t ), ( 3, t ), ( 3, t ) ], 15 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ) ], 0 )
                ]
                [ helpUpperSectionBonus ]

        Types.Fours ->
            helpEntry
                "Fours"
                (text "Score the sum of fours.")
                [ ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 4, t ), ( 5, f ) ], 4 )
                , ( [ ( 4, t ), ( 4, t ), ( 4, t ), ( 2, f ), ( 5, f ) ], 12 )
                , ( [ ( 4, t ), ( 4, t ), ( 4, t ), ( 4, t ), ( 4, t ) ], 20 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ) ], 0 )
                ]
                [ helpUpperSectionBonus ]

        Types.Fives ->
            helpEntry
                "Fives"
                (text "Score the sum of fives.")
                [ ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 4, f ), ( 5, t ) ], 5 )
                , ( [ ( 5, t ), ( 5, t ), ( 4, f ), ( 6, f ), ( 6, f ) ], 10 )
                , ( [ ( 5, t ), ( 5, t ), ( 5, t ), ( 5, t ), ( 5, t ) ], 25 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ) ], 0 )
                ]
                [ helpUpperSectionBonus ]

        Types.Sixes ->
            helpEntry
                "Sixes"
                (text "Score the sum of sixes.")
                [ ( [ ( 2, f ), ( 3, f ), ( 4, f ), ( 5, f ), ( 6, t ) ], 6 )
                , ( [ ( 6, t ), ( 6, t ), ( 6, t ), ( 2, f ), ( 1, f ) ], 18 )
                , ( [ ( 6, t ), ( 6, t ), ( 6, t ), ( 6, t ), ( 6, t ) ], 30 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ) ], 0 )
                ]
                [ helpUpperSectionBonus ]

        Types.ThreeOfKind ->
            helpEntry
                "Three of a kind"
                (text "Roll three or more dice of the same value to score the sum total of all five dice.")
                [ ( [ ( 1, t ), ( 2, f ), ( 1, t ), ( 2, f ), ( 1, t ) ], 7 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 3, f ) ], 11 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 10 )
                , ( [ ( 5, t ), ( 5, t ), ( 5, t ), ( 4, f ), ( 2, f ) ], 21 )
                , ( [ ( 4, f ), ( 4, f ), ( 5, f ), ( 6, f ), ( 6, f ) ], 0 )
                ]
                []

        Types.FourOfKind ->
            helpEntry
                "Four of a kind"
                (text "Roll four or more dice of the same value to score the sum total of all five dice.")
                [ ( [ ( 1, t ), ( 2, f ), ( 1, t ), ( 1, t ), ( 1, t ) ], 6 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 3, f ) ], 11 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 10 )
                , ( [ ( 5, f ), ( 5, f ), ( 5, f ), ( 4, f ), ( 2, f ) ], 0 )
                , ( [ ( 4, f ), ( 4, f ), ( 5, f ), ( 6, f ), ( 6, f ) ], 0 )
                ]
                []

        Types.FullHouse ->
            helpEntry
                "Full house"
                (text "Roll three dice of one value and two dice of another value to score 25 points.")
                [ ( [ ( 1, t ), ( 1, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 25 )
                , ( [ ( 6, t ), ( 3, t ), ( 6, t ), ( 3, t ), ( 6, t ) ], 25 )
                , ( [ ( 2, f ), ( 2, f ), ( 2, f ), ( 2, f ), ( 3, f ) ], 0 )
                , ( [ ( 2, f ), ( 2, f ), ( 2, f ), ( 2, f ), ( 2, f ) ], 0 )
                , ( [ ( 4, f ), ( 4, f ), ( 4, f ), ( 6, f ), ( 5, f ) ], 0 )
                ]
                [ helpYahtzeeWildcardPoints 25 ]

        Types.SmallStraight ->
            helpEntry
                "Small straight"
                (text "Roll four consecutive numbers to score 30 points.")
                [ ( [ ( 1, t ), ( 2, t ), ( 3, t ), ( 4, t ), ( 4, f ) ], 30 )
                , ( [ ( 2, t ), ( 3, t ), ( 4, t ), ( 5, t ), ( 3, f ) ], 30 )
                , ( [ ( 3, t ), ( 4, t ), ( 5, t ), ( 6, t ), ( 3, f ) ], 30 )
                , ( [ ( 4, t ), ( 2, t ), ( 1, t ), ( 3, t ), ( 1, f ) ], 30 )
                , ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 5, f ), ( 6, f ) ], 0 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 2, f ), ( 3, f ) ], 0 )
                ]
                [ helpYahtzeeWildcardPoints 30 ]

        Types.LargeStraight ->
            helpEntry
                "Large straight"
                (text "Roll five consecutive numbers to score 40 points.")
                [ ( [ ( 1, t ), ( 2, t ), ( 3, t ), ( 4, t ), ( 5, t ) ], 40 )
                , ( [ ( 2, t ), ( 3, t ), ( 4, t ), ( 5, t ), ( 6, t ) ], 40 )
                , ( [ ( 3, t ), ( 4, t ), ( 5, t ), ( 6, t ), ( 2, t ) ], 40 )
                , ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 4, f ), ( 6, f ) ], 0 )
                , ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 5, f ), ( 6, f ) ], 0 )
                , ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 4, f ), ( 4, f ) ], 0 )
                ]
                [ helpYahtzeeWildcardPoints 40 ]

        Types.Yahtzee ->
            helpEntry
                "Yahtzee"
                (text "Roll the same value on all five dice to score 50 points.")
                [ ( [ ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ) ], 50 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 50 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 2, f ) ], 0 )
                , ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 4, f ), ( 5, f ) ], 0 )
                ]
                [ helpYahtzeeBonus, helpYahtzeeWildcard ]

        Types.Chance ->
            helpEntry
                "Chance"
                (text "Score the sum total of all five dice.")
                [ ( [ ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ) ], 5 )
                , ( [ ( 1, t ), ( 2, t ), ( 3, t ), ( 4, t ), ( 5, t ) ], 15 )
                , ( [ ( 6, t ), ( 6, t ), ( 6, t ), ( 6, t ), ( 6, t ) ], 30 )
                , ( [ ( 1, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 9 )
                ]
                []

        Types.YahtzeeBonusCount ->
            ( "Help", [] )


helpEntry : String -> Html Types.Msg -> List ( List ( Types.Face, Bool ), Int ) -> List ( String, Html Types.Msg ) -> ( String, List ( String, Html Types.Msg ) )
helpEntry header summary examples extra =
    ( "Help | " ++ header
    , [ ( header
        , summary
        )
      , ( "Examples"
        , div
            []
            (List.map (\( faces, points ) -> example faces points) examples)
        )
      ]
        ++ extra
    )


helpUpperSectionBonus : ( String, Html msg )
helpUpperSectionBonus =
    ( "Upper section bonus"
    , helpUpperSectionBonusContent
    )


helpUpperSectionBonusContent : Html msg
helpUpperSectionBonusContent =
    text <|
        "If you score 63 or more in the upper section of the scoreboard, you will gain a 35 point bonus. "
            ++ "This can be achieved by rolling three of each number for every slot in the section."


helpYahtzeeBonus : ( String, Html msg )
helpYahtzeeBonus =
    ( "Yahtzee bonus"
    , helpYahtzeeBonusContent
    )


helpYahtzeeBonusContent : Html msg
helpYahtzeeBonusContent =
    text <|
        "If you roll a Yahtzee and score it in the Yahtzee score slot, every subsequent Yahtzee will automatically "
            ++ "score 100 bonus points. You do not get a bonus if you have scored a zero in the Yahtzee slot."


helpYahtzeeWildcard : ( String, Html msg )
helpYahtzeeWildcard =
    ( "Yahtzee wildcard"
    , text <|
        "If the Yahtzee slot is unavailable when you roll a Yahtzee and the corresponding slot in the upper section of "
            ++ "the scoreboard has already been filled, you may score any available lower section slot. "
            ++ "You will get the points specified in that slot."
    )


helpYahtzeeWildcardPoints : Int -> ( String, Html msg )
helpYahtzeeWildcardPoints points =
    ( "Yahtzee wildcard"
    , text <|
        "If you roll a Yahtzee after the Yahtzee score slot has already been filled and the corresponding slot in the "
            ++ "upper section of the scoreboard has also been filled, you may score the "
            ++ String.fromInt points
            ++ " points in this slot as a Yahtzee wildcard. You may do this even if the Yahtzee slot was filled with zero."
    )


example : List ( Types.Face, Bool ) -> Int -> Html Types.Msg
example faces points =
    let
        pointWord =
            if points == 1 then
                " point"

            else
                " points"
    in
    div
        [ class "dice-example" ]
        (exampleDice faces ++ [ div [] [ text <| "= " ++ String.fromInt points ++ pointWord ] ])
