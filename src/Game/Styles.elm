module Game.Styles exposing (cellStyle, derivedRowStyle, dieStyle, tableStyle, tdStyle, tdStyleClickable)

import Css exposing (..)


tableStyle : List Css.Style
tableStyle =
    [ borderCollapse collapse
    , textAlign left
    ]


cellStyle : List Css.Style
cellStyle =
    [ padding2 (rem 0.25) (rem 0.5)
    , borderWidth (px 1)
    , borderColor (hex "AAAAAA")
    , borderStyle solid
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
    ]


dieStyle : List Css.Style
dieStyle =
    [ marginBottom (rem 1)
    , height (pct 20)
    , cursor pointer
    , lastOfType
        [ marginBottom zero ]
    ]
