module Css.Model exposing (Model, initModel)


type alias Model =
    { id : Maybe Int
    , selector : String
    , property : String
    , value : String
    , type_ : String
    , title : String
    }


initModel : Model
initModel =
    Model Nothing "" "" "" "" ""
