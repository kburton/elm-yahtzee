module Game.Styles exposing (cellStyle, derivedRowStyle, dieStyle, tableStyle, tdStyle, tdStyleClickable)

import Css exposing (..)


tableStyle : List Css.Style
tableStyle =
    [ borderCollapse collapse
    , textAlign left
    , backgroundColor (hex "FFFFFF")
    ]


cellStyle : List Css.Style
cellStyle =
    [ padding2 (rem 0.25) (rem 0.5)
    , borderWidth (px 1)
    , borderColor (hex "AAAAAA")
    , borderStyle solid
    , minWidth (rem 3)
    ]


tdStyle : List Css.Style
tdStyle =
    cellStyle ++ [ textAlign center ]


tdStyleClickable : List Css.Style
tdStyleClickable =
    tdStyle
        ++ [ backgroundColor (hex "CCFFCC")
           , color (hex "006600")
           , cursor pointer
           , hover
                [ backgroundColor (hex "EEFFEE")
                ]
           ]


derivedRowStyle : List Css.Style
derivedRowStyle =
    [ backgroundColor (hex "DDDDDD")
    , display none
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
