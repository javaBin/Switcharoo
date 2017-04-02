module Css.Model exposing (Model, initModel)


type alias Model =
    { id : Int
    , selector : String
    , property : String
    , value : String
    , type_ : String
    , title : String
    }


initModel : Model
initModel =
    Model -1 "" "" "" "" ""
