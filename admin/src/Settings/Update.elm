module Settings.Update exposing (update)

import Settings.Model exposing (..)
import Settings.Messages exposing (..)
import Services.Services


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ServicesMsg msg ->
            let
                ( newServices, servicesCmd ) =
                    Services.Services.update msg model.services
            in
                ( { model | services = newServices }, Cmd.map ServicesMsg servicesCmd )
