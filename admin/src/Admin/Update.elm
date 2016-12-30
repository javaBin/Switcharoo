module Admin.Update exposing (update)

import Admin.Model exposing (..)
import Admin.Messages exposing (..)
import Slides.Slides
import Settings.Update
import Settings.Messages
import Services.Services
import Backend
import Slides.Slides
import Nav.Model exposing (Page(..))


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
                    Settings.Update.update msg model.settings
            in
                ( { model | settings = settings }, Cmd.map SettingsMsg cmd )

        UrlUpdate page ->
            ( { model | page = page }, Cmd.none )


updateUrl : Page -> Model -> ( Model, Cmd Msg )
updateUrl page m =
    let
        model =
            { m | page = page }
    in
        case page of
            SlidesPage ->
                ( model, Cmd.map SlideList <| Backend.getSlides Slides.Slides.decoder )

            SettingsPage ->
                ( model
                , Cmd.map SettingsMsg <|
                    Cmd.map Settings.Messages.ServicesMsg <|
                        Backend.getSettings Services.Services.decoder
                )
