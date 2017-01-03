module Settings.Update exposing (update)

import Settings.Model exposing (..)
import Settings.Messages exposing (..)
import Services.Services
import Styles.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ServicesMsg msg ->
            let
                ( newServices, servicesCmd ) =
                    Services.Services.update msg model.services
            in
                ( { model | services = newServices }, Cmd.map ServicesMsg servicesCmd )

        StylesMsg msg ->
            let
                ( newStyles, stylesCmd ) =
                    Styles.Update.update msg model.styles
            in
                ( { model | styles = newStyles }, Cmd.map StylesMsg stylesCmd )
