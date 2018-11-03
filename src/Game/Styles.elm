module Game.Styles exposing (dieStyle, rowStyle, scoreBonusStyle, scoreInfoStyle, scoreLabelStyle, scoreValueClickableStyle, scoreValueStyle, scoreboardStyle)

import Css exposing (..)


scoreboardStyle : List Css.Style
scoreboardStyle =
    [ displayFlex
    , flexDirection column
    , backgroundColor (hex "FFFFFF")
    , position absolute
    , top zero
    , right zero
    , bottom zero
    , left zero
    , borderTopColor (hex "BBBBBB")
    , borderTopWidth (px 1)
    , borderTopStyle solid
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


scoreLabelStyle : List Css.Style
scoreLabelStyle =
    [ flexGrow (num 1)
    , padding2 zero (em 0.5)
    ]


scoreValueStyle : List Css.Style
scoreValueStyle =
    [ padding2 zero (em 0.5)
    , alignSelf stretch
    , displayFlex
    , alignItems center
    , justifyContent center
    , minWidth (em 4)
    , borderLeftColor (hex "BBBBBB")
    , borderLeftWidth (px 1)
    , borderLeftStyle solid
    ]


scoreValueClickableStyle : List Css.Style
scoreValueClickableStyle =
    scoreValueStyle
        ++ [ backgroundColor (hex "CCFFCC")
           , color (hex "006600")
           , cursor pointer
           , hover
                [ backgroundColor (hex "EEFFEE")
                ]
           ]


scoreBonusStyle : List Css.Style
scoreBonusStyle =
    [ fontSize (em 0.8)
    , fontWeight bold
    , paddingRight (em 0.5)
    , color (hex "009900")
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
