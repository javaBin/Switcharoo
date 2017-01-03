module Styles.Model exposing (Model, initModel)

import Css.Model


type alias Model =
    { styles : List Css.Model.Model
    }


initModel : Model
initModel =
    Model []
