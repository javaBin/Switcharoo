module Admin.Model exposing (Model, initModel)

import Slides.Model
import Slides.Slides
import Settings.Model
import Admin.Messages exposing (..)
import Nav.Model
import Nav.Nav exposing (hashParser)
import Navigation
import Backend


type alias Model =
    { slides : Slides.Model.Model
    , settings : Settings.Model.Model
    , page : Nav.Model.Page
    }


initModel : Navigation.Location -> ( Model, Cmd Msg )
initModel location =
    let
        ( slides, slidesCmd ) =
            ( Slides.Model.init, Backend.getSlides Slides.Slides.decoder )

        page =
            hashParser location
    in
        ( Model slides Settings.Model.initModel page
        , Cmd.batch
            [ Cmd.map SlideList slidesCmd
            ]
        )
