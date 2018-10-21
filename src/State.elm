module State exposing (init, subscriptions, update)

import Dice.State
import Game.State
import Types


init : () -> ( Types.Model, Cmd Types.Msg )
init _ =
    let
        ( diceModel, diceCmd ) =
            Dice.State.init ()

        ( gameModel, gameCmd ) =
            Game.State.init ()

        cmds =
            Cmd.batch
                [ Cmd.map Types.DiceMsg diceCmd
                , Cmd.map Types.GameMsg gameCmd
                ]
    in
    ( { dice = diceModel
      , game = gameModel
      }
    , cmds
    )


update : Types.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg model =
    case msg of
        Types.DiceMsg diceMsg ->
            let
                ( diceModel, diceCmd ) =
                    Dice.State.update diceMsg model.dice
            in
            ( { model | dice = diceModel }, Cmd.map Types.DiceMsg diceCmd )

        Types.GameMsg gameMsg ->
            let
                ( gameModel, gameCmd ) =
                    Game.State.update gameMsg model.game
            in
            ( { model | game = gameModel }, Cmd.map Types.GameMsg gameCmd )


subscriptions : Types.Model -> Sub Types.Msg
subscriptions model =
    Sub.batch
        [ Sub.map Types.DiceMsg (Dice.State.subscriptions model.dice)
        ]
