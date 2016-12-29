module Services.Model exposing (..)

import Service


type alias Model =
    { settings : List Service.Model
    }


init : Model
init =
    Model []
