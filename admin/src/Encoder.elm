module Encoder exposing (..)

import Json.Encode exposing (Value, list, object, int, string)
import Model exposing (Setting)


settingsEncoder : List Setting -> Value
settingsEncoder settings =
    list <| List.map settingEncoder settings


settingEncoder : Setting -> Value
settingEncoder setting =
    object
        [ ( "id", int setting.id )
        , ( "key", string setting.key )
        , ( "hint", string setting.hint )
        , ( "value", object [ ( "type", string "string" ), ( "value", string setting.value ) ] )
        ]
