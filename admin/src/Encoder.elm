module Encoder exposing (..)

import Json.Encode exposing (Value, list, object, int, string)
import Model exposing (SettingModel)


settingsEncoder : List SettingModel -> Value
settingsEncoder settings =
    list <| List.map settingEncoder settings


settingEncoder : SettingModel -> Value
settingEncoder setting =
    object
        [ ( "id", int setting.id )
        , ( "key", string setting.key )
        , ( "hint", string setting.hint )
        , ( "value", object [ ( "type", string "string" ), ( "value", string setting.value ) ] )
        ]
