module View.Help exposing (help)

import Help.Model exposing (..)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Modal.Model
import Msg exposing (Msg)
import View.Dice exposing (exampleDice)


help : HelpKey -> Modal.Model.Model
help key =
    let
        t =
            True

        f =
            False
    in
    case key of
        ScoreOnes ->
            helpEntry
                "Aces"
                "Score the sum of ones."
                [ ( [ ( 1, t ), ( 2, f ), ( 3, f ), ( 4, f ), ( 5, f ) ], 1 )
                , ( [ ( 1, t ), ( 1, t ), ( 1, t ), ( 4, f ), ( 5, f ) ], 3 )
                , ( [ ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ) ], 5 )
                , ( [ ( 2, f ), ( 3, f ), ( 4, f ), ( 5, f ), ( 6, f ) ], 0 )
                ]
                [ bonusUpper ]

        ScoreTwos ->
            helpEntry
                "Twos"
                "Score the sum of twos."
                [ ( [ ( 1, f ), ( 2, t ), ( 3, f ), ( 4, f ), ( 5, f ) ], 2 )
                , ( [ ( 2, t ), ( 2, t ), ( 3, f ), ( 4, f ), ( 5, f ) ], 4 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 10 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ) ], 0 )
                ]
                [ bonusUpper ]

        ScoreThrees ->
            helpEntry
                "Threes"
                "Score the sum of threes."
                [ ( [ ( 1, f ), ( 2, f ), ( 3, t ), ( 4, f ), ( 5, f ) ], 3 )
                , ( [ ( 3, t ), ( 3, t ), ( 3, t ), ( 4, f ), ( 5, f ) ], 9 )
                , ( [ ( 3, t ), ( 3, t ), ( 3, t ), ( 3, t ), ( 3, t ) ], 15 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ) ], 0 )
                ]
                [ bonusUpper ]

        ScoreFours ->
            helpEntry
                "Fours"
                "Score the sum of fours."
                [ ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 4, t ), ( 5, f ) ], 4 )
                , ( [ ( 4, t ), ( 4, t ), ( 4, t ), ( 2, f ), ( 5, f ) ], 12 )
                , ( [ ( 4, t ), ( 4, t ), ( 4, t ), ( 4, t ), ( 4, t ) ], 20 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ) ], 0 )
                ]
                [ bonusUpper ]

        ScoreFives ->
            helpEntry
                "Fives"
                "Score the sum of fives."
                [ ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 4, f ), ( 5, t ) ], 5 )
                , ( [ ( 5, t ), ( 5, t ), ( 4, f ), ( 6, f ), ( 6, f ) ], 10 )
                , ( [ ( 5, t ), ( 5, t ), ( 5, t ), ( 5, t ), ( 5, t ) ], 25 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ) ], 0 )
                ]
                [ bonusUpper ]

        ScoreSixes ->
            helpEntry
                "Sixes"
                "Score the sum of sixes."
                [ ( [ ( 2, f ), ( 3, f ), ( 4, f ), ( 5, f ), ( 6, t ) ], 6 )
                , ( [ ( 6, t ), ( 6, t ), ( 6, t ), ( 2, f ), ( 1, f ) ], 18 )
                , ( [ ( 6, t ), ( 6, t ), ( 6, t ), ( 6, t ), ( 6, t ) ], 30 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ) ], 0 )
                ]
                [ bonusUpper ]

        ScoreThreeOfKind ->
            helpEntry
                "Three of a kind"
                "Roll three or more dice of the same value to score the sum total of all five dice."
                [ ( [ ( 1, t ), ( 2, f ), ( 1, t ), ( 2, f ), ( 1, t ) ], 7 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 3, f ) ], 11 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 10 )
                , ( [ ( 5, t ), ( 5, t ), ( 5, t ), ( 4, f ), ( 2, f ) ], 21 )
                , ( [ ( 4, f ), ( 4, f ), ( 5, f ), ( 6, f ), ( 6, f ) ], 0 )
                ]
                []

        ScoreFourOfKind ->
            helpEntry
                "Four of a kind"
                "Roll four or more dice of the same value to score the sum total of all five dice."
                [ ( [ ( 1, t ), ( 2, f ), ( 1, t ), ( 1, t ), ( 1, t ) ], 6 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 3, f ) ], 11 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 10 )
                , ( [ ( 5, f ), ( 5, f ), ( 5, f ), ( 4, f ), ( 2, f ) ], 0 )
                , ( [ ( 4, f ), ( 4, f ), ( 5, f ), ( 6, f ), ( 6, f ) ], 0 )
                ]
                []

        ScoreFullHouse ->
            helpEntry
                "Full house"
                "Roll three dice of one value and two dice of another value to score 25 points."
                [ ( [ ( 1, t ), ( 1, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 25 )
                , ( [ ( 6, t ), ( 3, t ), ( 6, t ), ( 3, t ), ( 6, t ) ], 25 )
                , ( [ ( 2, f ), ( 2, f ), ( 2, f ), ( 2, f ), ( 3, f ) ], 0 )
                , ( [ ( 2, f ), ( 2, f ), ( 2, f ), ( 2, f ), ( 2, f ) ], 0 )
                , ( [ ( 4, f ), ( 4, f ), ( 4, f ), ( 6, f ), ( 5, f ) ], 0 )
                ]
                [ yahtzeeWildcardPoints 25 ]

        ScoreSmallStraight ->
            helpEntry
                "Small straight"
                "Roll four consecutive numbers to score 30 points."
                [ ( [ ( 1, t ), ( 2, t ), ( 3, t ), ( 4, t ), ( 4, f ) ], 30 )
                , ( [ ( 2, t ), ( 3, t ), ( 4, t ), ( 5, t ), ( 3, f ) ], 30 )
                , ( [ ( 3, t ), ( 4, t ), ( 5, t ), ( 6, t ), ( 3, f ) ], 30 )
                , ( [ ( 4, t ), ( 2, t ), ( 1, t ), ( 3, t ), ( 1, f ) ], 30 )
                , ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 5, f ), ( 6, f ) ], 0 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 2, f ), ( 3, f ) ], 0 )
                ]
                [ yahtzeeWildcardPoints 30 ]

        ScoreLargeStraight ->
            helpEntry
                "Large straight"
                "Roll five consecutive numbers to score 40 points."
                [ ( [ ( 1, t ), ( 2, t ), ( 3, t ), ( 4, t ), ( 5, t ) ], 40 )
                , ( [ ( 2, t ), ( 3, t ), ( 4, t ), ( 5, t ), ( 6, t ) ], 40 )
                , ( [ ( 3, t ), ( 4, t ), ( 5, t ), ( 6, t ), ( 2, t ) ], 40 )
                , ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 4, f ), ( 6, f ) ], 0 )
                , ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 5, f ), ( 6, f ) ], 0 )
                , ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 4, f ), ( 4, f ) ], 0 )
                ]
                [ yahtzeeWildcardPoints 40 ]

        ScoreYahtzee ->
            helpEntry
                "Yahtzee"
                "Roll the same value on all five dice to score 50 points."
                [ ( [ ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ) ], 50 )
                , ( [ ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 50 )
                , ( [ ( 1, f ), ( 1, f ), ( 1, f ), ( 1, f ), ( 2, f ) ], 0 )
                , ( [ ( 1, f ), ( 2, f ), ( 3, f ), ( 4, f ), ( 5, f ) ], 0 )
                ]
                [ bonusYahtzee, yahtzeeWildcard ]

        ScoreChance ->
            helpEntry
                "Chance"
                "Score the sum total of all five dice."
                [ ( [ ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ), ( 1, t ) ], 5 )
                , ( [ ( 1, t ), ( 2, t ), ( 3, t ), ( 4, t ), ( 5, t ) ], 15 )
                , ( [ ( 6, t ), ( 6, t ), ( 6, t ), ( 6, t ), ( 6, t ) ], 30 )
                , ( [ ( 1, t ), ( 2, t ), ( 2, t ), ( 2, t ), ( 2, t ) ], 9 )
                ]
                []

        BonusUpper ->
            { title = "Help | Upper section bonus"
            , sections = [ bonusUpper ]
            }

        BonusYahtzee ->
            { title = "Help | Yahtzee bonus"
            , sections = [ bonusYahtzee ]
            }


bonusUpper : Modal.Model.Section
bonusUpper =
    { header = "Upper section bonus"
    , content =
        text <|
            "If you score 63 or more in the upper section of the scoreboard, you will gain a 35 point bonus. "
                ++ "This can be achieved by rolling three of each number for every slot in the section."
    }


bonusYahtzee : Modal.Model.Section
bonusYahtzee =
    { header = "Yahtzee bonus"
    , content =
        text <|
            "If you roll a Yahtzee and score it in the Yahtzee score slot, every subsequent Yahtzee will automatically "
                ++ "score 100 bonus points. You do not get a bonus if you have scored a zero in the Yahtzee slot."
    }


yahtzeeWildcard : Modal.Model.Section
yahtzeeWildcard =
    { header = "Yahtzee wildcard"
    , content =
        text <|
            "If the Yahtzee slot is unavailable when you roll a Yahtzee and the corresponding slot in the upper section of "
                ++ "the scoreboard has already been filled, you may score any available lower section slot. "
                ++ "You will get the points specified in that slot."
    }


yahtzeeWildcardPoints : Int -> Modal.Model.Section
yahtzeeWildcardPoints points =
    { header = "Yahtzee wildcard"
    , content =
        text <|
            "If you roll a Yahtzee after the Yahtzee score slot has already been filled and the corresponding slot in the "
                ++ "upper section of the scoreboard has also been filled, you may score the "
                ++ String.fromInt points
                ++ " points in this slot as a Yahtzee wildcard. You may do this even if the Yahtzee slot was filled with zero."
    }


helpEntry : String -> String -> List ( List ( Int, Bool ), Int ) -> List Modal.Model.Section -> Modal.Model.Model
helpEntry header content exampleList extraSections =
    { title = "Help | " ++ header
    , sections =
        [ { header = header, content = text content }
        , examples exampleList
        ]
            ++ extraSections
    }


examples : List ( List ( Int, Bool ), Int ) -> Modal.Model.Section
examples es =
    { header = "Examples"
    , content = div [] (List.map example es)
    }


example : ( List ( Int, Bool ), Int ) -> Html Msg
example ( faces, score ) =
    let
        pointsWord =
            if score == 1 then
                " point"

            else
                " points"
    in
    div
        [ class "help__example" ]
        [ div
            []
            (exampleDice faces
                ++ [ text <| "= " ++ String.fromInt score ++ pointsWord ]
            )
        ]
