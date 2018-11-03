module Styles exposing (containerStyle, dicePaneStyle, globalStyle, menuBarStyle, messagePaneStyle, scoreboardPaneStyle)

import Css exposing (..)
import Css.Global as Global
import Html.Styled exposing (Html)
import Style.Utils as Utils


globalStyle : Html msg
globalStyle =
    Global.global
        [ Global.everything
            [ boxSizing borderBox ]
        , Global.selector "html, body"
            ([ margin zero
             , padding zero
             , height (pct 100)
             ]
                ++ Utils.disableUserSelect
            )
        ]


containerStyle : List Css.Style
containerStyle =
    [ fontSize (vh 2.8)
    , fontFamilies [ "sans-serif" ]
    , height (pct 100)
    , displayFlex
    , flexDirection column
    ]


menuBarStyle : List Css.Style
menuBarStyle =
    [ flexShrink zero
    , displayFlex
    , justifyContent spaceBetween
    , alignItems center
    , backgroundColor (hex "333333")
    , color (hex "FFFFFF")
    , fontWeight bold
    , padding (em 0.5)
    , height (em 2)
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
    , padding2 zero (em 0.5)
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
