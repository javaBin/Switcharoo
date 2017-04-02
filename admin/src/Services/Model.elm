module Services.Model exposing (..)

import Service.Model


type alias Model =
    { settings : List Service.Model.Model
    }


init : Model
init =
    Model []
