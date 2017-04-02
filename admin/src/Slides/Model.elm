module Slides.Model exposing (Model, init)

import Slide.Model
import Modal.Model


type alias Model =
    { slides : List Slide.Model.Model
    , modal : Modal.Model.Model
    }


init : Model
init =
    Model [] Modal.Model.init
