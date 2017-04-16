module Slide.Model exposing (..)


type alias Model =
    { slide : Slide
    , deleteMode : Bool
    }


type alias Slide =
    { id : Int
    , name : String
    , title : String
    , body : String
    , visible : Bool
    , index : Int
    , type_ : String
    , color : Maybe String
    }


initSlide : Slide
initSlide =
    Slide -1 "" "" "" False 10 "" Nothing


initModel : Model
initModel =
    Model initSlide False
