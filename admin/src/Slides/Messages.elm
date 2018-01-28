module Slides.Messages exposing (Msg(..))

import Http
import Slide.Model
import Slide.Messages
import Models.Slides


type Msg
    = GetSlides
    | SlidesResponse (Result Http.Error (List Models.Slides.Slide))
    | Slide Models.Slides.SlideModel Slide.Messages.Msg
    | NewSlide
