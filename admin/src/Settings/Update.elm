module Settings.Update exposing (update)

import Settings.Model exposing (..)
import Settings.Messages exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ServicesMsg msg ->
            ( model, Cmd.none )
