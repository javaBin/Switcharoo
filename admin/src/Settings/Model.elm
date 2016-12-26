module Settings.Model exposing (..)

import Setting


type alias Model =
    { settings : List Setting.Model
    }


init : Model
init =
    Model []
