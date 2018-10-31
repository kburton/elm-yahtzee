module Styles exposing (containerStyle, dicePaneStyle, messagePaneStyle, scoreboardPaneStyle)

import Css exposing (..)


containerStyle : List Css.Style
containerStyle =
    [ fontSize (vh 2.8)
    , fontFamilies [ "sans-serif" ]
    , height (pct 100)
    , displayFlex
    , flexDirection column
    ]


scoreboardPaneStyle : List Css.Style
scoreboardPaneStyle =
    [ flexShrink zero
    , flexGrow (num 1)
    , position relative
    ]


dicePaneStyle : List Css.Style
dicePaneStyle =
    [ flexShrink zero
    , height (vw 22)
    , displayFlex
    , property "justify-content" "space-evenly"
    , padding2 (vw 2) zero
    , backgroundColor (hex "#EEEEEE")
    ]


messagePaneStyle : List Css.Style
messagePaneStyle =
    [ displayFlex
    , alignItems center
    , justifyContent center
    , padding2 zero (rem 1)
    , minHeight (em 3.6)
    , backgroundColor (hex "CCCCFF")
    , textAlign center
    , cursor pointer
    ]
