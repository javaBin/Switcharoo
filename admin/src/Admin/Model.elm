module Admin.Model exposing (Model, initModel)

import Slides.Model
import Slides.Slides
import Services.Services
import Services.Model
import Admin.Messages exposing (..)
import Nav.Model
import Nav.Nav exposing (hashParser)
import Navigation
import Backend


type alias Model =
    { slides : Slides.Model.Model
    , settings : Services.Model.Model
    , page : Nav.Model.Page
    }


initModel : Navigation.Location -> ( Model, Cmd Msg )
initModel location =
    let
        ( slides, slidesCmd ) =
            ( Slides.Model.init, Backend.getSlides Slides.Slides.decoder )

        ( settings, settingsCmd ) =
            ( Services.Model.init, Backend.getSettings Services.Services.decoder )

        page =
            hashParser location
    in
        ( Model slides settings page
        , Cmd.batch
            [ Cmd.map SlideList slidesCmd
            , Cmd.map SettingsMsg settingsCmd
            ]
        )
