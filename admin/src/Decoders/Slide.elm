module Decoders.Slide exposing (decoder, slideDecoder)

import Json.Decode exposing (Decoder, list, nullable, int, string, bool)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Models.Slides


decoder : Decoder (List Models.Slides.Slide)
decoder =
    list slideDecoder


slideDecoder : Decoder Models.Slides.Slide
slideDecoder =
    decode Models.Slides.Slide
        |> required "id" int
        |> required "name" string
        |> required "title" string
        |> required "body" string
        |> required "visible" bool
        |> required "index" int
        |> required "type" string
        |> optional "color" (nullable string) Nothing
