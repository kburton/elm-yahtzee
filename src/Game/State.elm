module Game.State exposing (init, update)

import Dice.Types
import Game.Types
import Random
import Types


init : () -> ( Game.Types.Model, Cmd Types.Msg )
init _ =
    ( { games = [ Game.Types.newScoreboard ], turn = 1, roll = 1 }, Cmd.none )


update : Game.Types.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg model =
    let
        roll index =
            Random.generate (Dice.Types.SetFlips index) (Random.int 8 25)
    in
    case msg of
        Game.Types.Roll ->
            if Game.Types.maxRollsReached model.game then
                ( model, Cmd.none )

            else
                let
                    gameModel =
                        model.game

                    newGameModel =
                        { gameModel | roll = model.game.roll + 1 }
                in
                ( { model | game = newGameModel }
                , Cmd.map Types.DiceMsg (Cmd.batch <| List.map (\( i, _ ) -> roll i) <| Dice.Types.activeDice model.dice)
                )
