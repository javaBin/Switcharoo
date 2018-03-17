module Models.Slides exposing (Slides, SlideModel, Slide, initSlide, initSlideModel, initSlides)

import Popup


type alias Slides =
    { slides : List SlideModel
    , newSlide : Maybe (Popup.State SlideModel)
    , moving : Maybe SlideModel
    }


type alias SlideModel =
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


initSlides : Slides
initSlides =
    Slides [] Nothing Nothing


initSlide : Slide
initSlide =
    Slide -1 "" "" "" False 10 "" Nothing


initSlideModel : SlideModel
initSlideModel =
    SlideModel initSlide False
