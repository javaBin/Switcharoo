module Decoder exposing (..)

import Model exposing (..)
import Json.Decode exposing (Decoder, succeed, field, string, int, list, at)
import Json.Decode.Extra exposing ((|:))


stylesDecoder : Decoder (List CssModel)
stylesDecoder =
    list cssDecoder


cssDecoder : Decoder CssModel
cssDecoder =
    succeed CssModel
        |: field "id" int
        |: field "selector" string
        |: field "property" string
        |: field "value" string
        |: field "type" string
        |: field "title" string


settingsDecoder : Decoder (List SettingModel)
settingsDecoder =
    list settingDecoder


settingDecoder : Decoder SettingModel
settingDecoder =
    succeed SettingModel
        |: field "id" int
        |: field "key" string
        |: field "hint" string
        |: at [ "value", "value" ] string
