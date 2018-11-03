module State exposing (init, subscriptions, update)

import Game.State
import Game.Types
import Html.Styled
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
      , menuOpen = False
      , modal = Nothing
      }
    , cmds
    )


update : Types.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg model =
    case msg of
        Types.GameMsg gameMsg ->
            case gameMsg of
                Game.Types.ShowHelp header sections ->
                    ( { model | modal = Just ( header, List.map (\( h, s ) -> ( h, Html.Styled.map Types.GameMsg s )) sections ) }, Cmd.none )

                _ ->
                    let
                        ( gameModel, gameCmd ) =
                            Game.State.update gameMsg model.game
                    in
                    ( { model | game = gameModel }, Cmd.map Types.GameMsg gameCmd )

        Types.ToggleMenu ->
            ( { model | menuOpen = not model.menuOpen }, Cmd.none )

        Types.OpenModal payload ->
            ( { model | modal = Just payload }, Cmd.none )

        Types.CloseModal ->
            ( { model | modal = Nothing }, Cmd.none )

        Types.NoOp ->
            ( model, Cmd.none )


subscriptions : Types.Model -> Sub Types.Msg
subscriptions model =
    Sub.batch
        [ Sub.map Types.GameMsg (Game.State.subscriptions model.game)
        ]
