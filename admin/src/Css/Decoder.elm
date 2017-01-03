module Css.Decoder exposing (..)

import Css.Model exposing (..)
import Json.Decode exposing (Decoder, succeed, field, string, int, map)
import Json.Decode.Extra exposing ((|:))


decoder : Decoder Model
decoder =
    succeed Model
        |: (map Just <| field "id" int)
        |: field "selector" string
        |: field "property" string
        |: field "value" string
        |: field "type" string
        |: field "title" string
