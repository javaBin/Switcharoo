module Decoder exposing (..)

import Models.ConferenceModel exposing (..)
import Json.Decode exposing (Decoder, andThen, succeed, string, int, list, at, bool)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Models.Conference exposing (Conference)
import Service.Model
import Models.Overlay exposing (Overlay, Placement(..))


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


servicesDecoder : Decoder (List Service.Model.Model)
servicesDecoder =
    list serviceDecoder


serviceDecoder : Decoder Service.Model.Model
serviceDecoder =
    decode Service.Model.Model
        |> required "id" int
        |> required "key" string
        |> required "value" bool


overlayDecoder : Decoder Overlay
overlayDecoder =
    decode Overlay
        |> required "enabled" bool
        |> required "image" string
        |> required "placement" (andThen placement string)
        |> required "width" string
        |> required "height" string


placement : String -> Decoder Placement
placement val =
    case val of
        "TopLeft" ->
            succeed TopLeft

        "TopRight" ->
            succeed TopRight

        "BottomLeft" ->
            succeed BottomLeft

        "BottomRight" ->
            succeed BottomRight

        _ ->
            Json.Decode.fail <| "Invalid role " ++ val
