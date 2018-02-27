module Decoder exposing (..)

import Models.ConferenceModel exposing (..)
import Json.Decode exposing (Decoder, succeed, string, int, list, at)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Models.Conference exposing (Conference)


stylesDecoder : Decoder (List CssModel)
stylesDecoder =
    list cssDecoder


cssDecoder : Decoder CssModel
cssDecoder =
    decode CssModel
        |> required "id" int
        |> required "selector" string
        |> required "property" string
        |> required "value" string
        |> required "type" string
        |> required "title" string


settingsDecoder : Decoder (List Setting)
settingsDecoder =
    list settingDecoder


settingDecoder : Decoder Setting
settingDecoder =
    decode Setting
        |> required "id" int
        |> required "key" string
        |> required "hint" string
        |> requiredAt [ "value", "value" ] string


conferencesDecoder : Decoder (List Conference)
conferencesDecoder =
    list conferenceDecoder


conferenceDecoder : Decoder Conference
conferenceDecoder =
    decode Conference
        |> required "id" int
        |> required "name" string
