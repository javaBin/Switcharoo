module Css.Update exposing (update)

import Css.Model exposing (..)
import Css.Messages exposing (..)
import Backend


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update value ->
            ( { model | value = value }, Cmd.none )

        Save ->
            ( model, Backend.editStyle model )

        Request (Err _) ->
            ( model, Cmd.none )

        Request (Ok _) ->
            ( model, Cmd.none )
