module State exposing (init, subscriptions, update)

import Game.State
import Types


init : () -> ( Types.Model, Cmd Types.Msg )
init _ =
    let
        ( gameModel, gameCmd ) =
            Game.State.init ()

        cmds =
            Cmd.batch
                [ Cmd.map Types.GameMsg gameCmd
                ]
    in
    ( { game = gameModel
      }
    , cmds
    )


update : Types.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg model =
    case msg of
        Types.GameMsg gameMsg ->
            let
                ( gameModel, gameCmd ) =
                    Game.State.update gameMsg model.game
            in
            ( { model | game = gameModel }, Cmd.map Types.GameMsg gameCmd )

        Types.NoOp ->
            ( model, Cmd.none )


subscriptions : Types.Model -> Sub Types.Msg
subscriptions model =
    Sub.batch
        [ Sub.map Types.GameMsg (Game.State.subscriptions model.game)
        ]
