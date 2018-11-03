module Style.Utils exposing (disableUserSelect)

import Css exposing (..)


disableUserSelect : List Style
disableUserSelect =
    [ property "-webkit-touch-callout" "none"
    , property "-webkit-user-select" "none"
    , property "-khtml-user-select" "none"
    , property "-moz-user-select" "none"
    , property "-ms-user-select" "none"
    , property "user-select" "none"
    ]
