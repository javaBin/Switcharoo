module Decoder.Data exposing (decoder)

import Json.Decode exposing (Decoder, field)
import Decoder.Slides
import Models exposing (SlideWrapper)


decoder : Decoder (List SlideWrapper)
decoder =
    field "slides" Decoder.Slides.decoder
