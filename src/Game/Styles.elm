module Game.Styles exposing (dieStyle, exampleDiceStyle, exampleDieStyle, exampleScoreStyle, rowStyle, scoreBonusStyle, scoreInfoStyle, scoreLabelStyle, scoreValueClickableStyle, scoreValueStyle, scoreboardDividerStyle, scoreboardStyle)

import Css exposing (..)


scoreboardStyle : List Css.Style
scoreboardStyle =
    [ displayFlex
    , flexDirection column
    , backgroundColor (hex "EEEEEE")
    , backgroundImage (url "paper.jpg")
    , backgroundRepeat repeat
    , position absolute
    , top zero
    , right zero
    , bottom zero
    , left zero
    ]


rowStyle : List Css.Style
rowStyle =
    [ flexGrow (num 1)
    , displayFlex
    , alignItems center
    , justifyContent spaceBetween
    , borderBottomColor (hex "BBBBBB")
    , borderBottomWidth (px 1)
    , borderBottomStyle solid
    ]


scoreboardDividerStyle : List Css.Style
scoreboardDividerStyle =
    [ height (px 3)
    , borderBottomColor (hex "BBBBBB")
    , borderBottomWidth (px 1)
    , borderBottomStyle solid
    ]


scoreLabelStyle : List Css.Style
scoreLabelStyle =
    [ flexGrow (num 1)
    , padding2 zero (em 0.5)
    ]


scoreValueStyle : List Css.Style
scoreValueStyle =
    [ alignSelf stretch
    , displayFlex
    , alignItems center
    , justifyContent center
    , width (em 4)
    , borderLeftColor (hex "BBBBBB")
    , borderLeftWidth (px 1)
    , borderLeftStyle solid
    , fontFamilies [ "Kalam", "cursive" ]
    , fontWeight bold
    , paddingTop (em 0.2)
    , color (hex "0000FF")
    ]


scoreValueClickableStyle : List Css.Style
scoreValueClickableStyle =
    scoreValueStyle
        ++ [ backgroundColor (hex "AAFFAA55")
           , color (hex "006600")
           , cursor pointer
           , hover
                [ backgroundColor (hex "EEFFEE")
                ]
           ]


scoreBonusStyle : List Css.Style
scoreBonusStyle =
    [ fontFamilies [ "Kalam", "cursive" ]
    , fontWeight bold
    , padding4 (em 0.2) (em 0.5) zero (em 0.5)
    , color (hex "0000FF")
    ]


scoreInfoStyle : List Css.Style
scoreInfoStyle =
    [ fontSize (em 0.8)
    , paddingRight (em 0.5)
    , color (hex "999999")
    ]


dieStyle : List Css.Style
dieStyle =
    [ cursor pointer
    , width (vw 18)
    ]
        ++ noTouchHighlight


exampleDiceStyle : List Css.Style
exampleDiceStyle =
    [ displayFlex
    , alignItems center
    , marginTop (em 0.5)
    ]


exampleDieStyle : List Css.Style
exampleDieStyle =
    [ marginRight (em 0.25)
    , width (vw 10)
    , height (vw 10)
    ]


exampleScoreStyle : List Css.Style
exampleScoreStyle =
    [ marginLeft (em 0.5)
    ]


noTouchHighlight : List Css.Style
noTouchHighlight =
    [ property "-webkit-touch-callout" "none"
    , property "-webkit-user-select" "none"
    , property "-khtml-user-select" "none"
    , property "-moz-user-select" "none"
    , property "-ms-user-select" "none"
    , property "user-select" "none"
    , property "-webkit-tap-highlight-color" "transparent"
    ]
