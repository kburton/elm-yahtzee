module Game.State exposing (init, update)

import Game.Types as Types


init : () -> ( Types.Model, Cmd Types.Msg )
init _ =
    ( { games = [ Types.newScoreboard ], turn = 1, roll = 1 }, Cmd.none )


update : Types.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg model =
    case msg of
        Types.Roll ->
            ( if Types.maxRollsReached model then
                model

              else
                { model | roll = model.roll + 1 }
            , Cmd.none
            )
