module Styles exposing (containerStyle, diceContainerStyle, dicePaneStyle, mainPaneStyle, messagePaneStyle, scoreboardPaneStyle, wrapperPaneStyle)

import Css exposing (..)


containerStyle : List Css.Style
containerStyle =
    [ fontSize (px 16)
    , fontFamilies [ "sans-serif" ]
    , height (pct 100)
    , displayFlex
    , flexDirection column
    ]


mainPaneStyle : List Css.Style
mainPaneStyle =
    [ position relative
    , displayFlex
    , flexGrow (num 1)
    , margin (rem 1)
    ]


dicePaneStyle : List Css.Style
dicePaneStyle =
    [ flexShrink zero
    , height (pct 100)
    , marginRight (rem 1)
    ]


diceContainerStyle : List Css.Style
diceContainerStyle =
    [ displayFlex
    , flexDirection column
    , height (pct 100)
    , minWidth (vh 18)
    ]


scoreboardPaneStyle : List Css.Style
scoreboardPaneStyle =
    [ flexShrink zero
    ]


messagePaneStyle : List Css.Style
messagePaneStyle =
    [ padding (rem 1)
    , backgroundColor (hex "CCCCFF")
    , textAlign center
    , cursor pointer
    ]


wrapperPaneStyle : List Css.Style
wrapperPaneStyle =
    [ position absolute
    , displayFlex
    , justifyContent center
    , alignItems center
    , top zero
    , right zero
    , bottom zero
    , left zero
    ]
