module Utils.Date exposing (formatDate)

import Time


formatDate : Time.Zone -> Time.Posix -> String
formatDate tz posixTime =
    let
        dayNum =
            Time.toDay tz posixTime

        day =
            String.fromInt dayNum ++ daySuffix dayNum

        month =
            monthName <| Time.toMonth tz posixTime

        year =
            String.fromInt <| Time.toYear tz posixTime
    in
    String.join " " [ day, month, year ]


monthName : Time.Month -> String
monthName month =
    case month of
        Time.Jan ->
            "January"

        Time.Feb ->
            "February"

        Time.Mar ->
            "March"

        Time.Apr ->
            "April"

        Time.May ->
            "May"

        Time.Jun ->
            "June"

        Time.Jul ->
            "July"

        Time.Aug ->
            "August"

        Time.Sep ->
            "September"

        Time.Oct ->
            "October"

        Time.Nov ->
            "November"

        Time.Dec ->
            "December"


daySuffix : Int -> String
daySuffix day =
    let
        lastDigitOf =
            modBy 10
    in
    case lastDigitOf day of
        1 ->
            "st"

        2 ->
            "nd"

        3 ->
            "rd"

        _ ->
            "th"
