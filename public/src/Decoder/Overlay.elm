module Decoder.Overlay exposing (decoder)

import Models exposing (Overlay)
import Json.Decode exposing (Decoder, andThen, succeed, list, string, fail, field, maybe, dict, map)
import Json.Decode.Extra exposing ((|:))
import Dict


decoder : Decoder Overlay
decoder =
    succeed Overlay
        |: (field "image" string)
        |: (field "style" decodeStyles)


decodeStyles : Decoder (List ( String, String ))
decodeStyles =
    map Dict.toList <| dict string
