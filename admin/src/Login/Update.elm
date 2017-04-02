module Login.Update exposing (update)

import Login.Model exposing (..)
import Login.Messages exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Message ->
            ( model, Cmd.none )
