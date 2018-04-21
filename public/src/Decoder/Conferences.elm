module Decoder.Conferences exposing (decoder)

import Json.Decode exposing (Decoder, succeed, field, list, string, int)
import Json.Decode.Extra exposing ((|:))
import Models.Conference


decoder : Decoder (List Models.Conference.Conference)
decoder =
    list conference


conference : Decoder Models.Conference.Conference
conference =
    succeed Models.Conference.Conference
        |: (field "name" string)
        |: (field "id" int)
