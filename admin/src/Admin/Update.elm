module Admin.Update exposing (update)

import Admin.Model exposing (..)
import Admin.Messages exposing (..)
import Slides.Slides
import Services.Services


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SlideList msg ->
            let
                ( slides, cmd ) =
                    Slides.Slides.update msg model.slides
            in
                ( { model | slides = slides }, Cmd.map SlideList cmd )

        SettingsMsg msg ->
            let
                ( settings, cmd ) =
                    Services.Services.update msg model.settings
            in
                ( { model | settings = settings }, Cmd.map SettingsMsg cmd )

        UrlUpdate page ->
            ( { model | page = page }, Cmd.none )
