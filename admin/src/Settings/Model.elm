module Settings.Model exposing (Model, initModel)

import Services.Model
import Styles.Model


type alias Model =
    { services : Services.Model.Model
    , styles : Styles.Model.Model
    }


initModel : Model
initModel =
    Model Services.Model.init Styles.Model.initModel
