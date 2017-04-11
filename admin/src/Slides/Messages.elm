module Slides.Messages exposing (Msg(..))

import Http
import Slide.Model
import Slide.Messages
import Modal.Messages


type Msg
    = GetSlides
    | SlidesResponse (Result Http.Error (List Slide.Model.Slide))
    | Slide Slide.Model.Model Slide.Messages.Msg
    | NewSlideModal Modal.Messages.Msg
