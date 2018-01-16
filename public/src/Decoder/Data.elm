module Decoder.Data exposing (decoder)

import Json.Decode exposing (Decoder, succeed, field, maybe)
import Json.Decode.Extra exposing ((|:))
import Decoder.Slides
import Decoder.Overlay
import Models exposing (Data)


decoder : Decoder Data
decoder =
    succeed Data
        |: (field "slides" Decoder.Slides.decoder)
        |: maybe (field "overlay" Decoder.Overlay.decoder)
