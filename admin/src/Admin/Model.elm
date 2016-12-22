module Admin.Model exposing (Model, initModel)

import Slides
import Settings
import Admin.Messages exposing (..)


type alias Model =
    { slides : Slides.Model
    , settings : Settings.Model
    }


initModel : ( Model, Cmd Msg )
initModel =
    let
        ( slides, slidesCmd ) =
            Slides.init

        ( settings, settingsCmd ) =
            Settings.init
    in
        ( Model slides settings
        , Cmd.batch
            [ Cmd.map SlideList slidesCmd
            , Cmd.map SettingsMsg settingsCmd
            ]
        )
