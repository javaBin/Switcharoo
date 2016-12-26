module Modal.Model exposing (..)

import Slide.Model


type alias Model =
    { show : Bool
    , id : String
    , slide : Slide.Model.Model
    }


init : Model
init =
    Model False "MediaInputId" Slide.Model.initModel
