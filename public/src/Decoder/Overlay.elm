module Decoder.Overlay exposing (decoder)

import Models exposing (Overlay)
import Json.Decode exposing (Decoder, andThen, succeed, list, string, fail, field, maybe, dict, map, bool)
import Json.Decode.Extra exposing ((|:))
import Dict


decoder : Decoder Overlay
decoder =
    succeed Overlay
        |: (field "enabled" bool)
        |: (field "image" string)
        |: (field "placement" (andThen decodePlacement string))
        |: (field "width" string)
        |: (field "height" string)


decodePlacement : String -> Decoder String
decodePlacement val =
    case val of
        "TopLeft" ->
            succeed "top-left"

        "TopRight" ->
            succeed "top-right"

        "BottomLeft" ->
            succeed "bottom-left"

        _ ->
            succeed "bottom-right"
