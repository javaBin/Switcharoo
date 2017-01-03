module Css.Update exposing (update)

import Css.Model exposing (..)
import Css.Messages exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Message ->
            ( model, Cmd.none )
