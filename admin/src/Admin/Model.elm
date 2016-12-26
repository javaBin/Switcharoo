module Admin.Model exposing (Model, initModel)

import Slides.Model
import Slides.Slides
import Settings.Settings
import Settings.Model
import Admin.Messages exposing (..)
import Backend


type alias Model =
    { slides : Slides.Model.Model
    , settings : Settings.Model.Model
    }


initModel : ( Model, Cmd Msg )
initModel =
    let
        ( slides, slidesCmd ) =
            ( Slides.Model.init, Backend.getSlides Slides.Slides.decoder )

        ( settings, settingsCmd ) =
            ( Settings.Model.init, Backend.getSettings Settings.Settings.decoder )
    in
        ( Model slides settings
        , Cmd.batch
            [ Cmd.map SlideList slidesCmd
            , Cmd.map SettingsMsg settingsCmd
            ]
        )
