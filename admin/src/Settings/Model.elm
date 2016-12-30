module Settings.Model exposing (Model, initModel)

import Services.Model


type alias Model =
    { services : Services.Model.Model
    }


initModel : Model
initModel =
    Model Services.Model.init
