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
    , backgroundColor (hex "EEEEEE")
    ]


messagePaneStyle : Bool -> List Css.Style
messagePaneStyle tutorialMode =
    [ displayFlex
    , position relative
    , alignItems center
    , justifyContent center
    , padding2 zero (rem 1)
    , minHeight (vw 20)
    , backgroundColor (hex "CCCCFF")
    , textAlign center
    , cursor pointer
    ]
        ++ (if tutorialMode then
                [ fontSize (vh 2.2)
                , before
                    [ property "content" "'TUTORIAL'"
                    , position absolute
                    , bottom zero
                    , right zero
                    , fontSize (vh 1.6)
                    , fontWeight bold
                    , color (hex "999999")
                    , padding (em 0.2)
                    ]
                ]

            else
                [ fontSize inherit ]
           )
