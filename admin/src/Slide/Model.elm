module Slide.Model exposing (..)


type alias Model =
    { id : Int
    , name : String
    , title : String
    , body : String
    , visible : Bool
    , index : Int
    , type_ : String
    }


initModel : Model
initModel =
    Model -1 "" "" "" False 10 ""
