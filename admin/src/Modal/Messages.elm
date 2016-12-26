module Modal.Messages exposing (..)

import Slide.Model
import Slide.Messages
import Http


type Msg
    = Show
    | Hide
    | Edit Slide.Model.Model
    | CreateSlide
    | CreateResponse (Result Http.Error Slide.Model.Model)
    | CurrentSlide Slide.Messages.Msg
