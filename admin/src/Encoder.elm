module Encoder exposing (..)

import Json.Encode exposing (Value, list, object, int, string)
import Model exposing (Setting, CssModel)


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


stylesEncoder : List CssModel -> Value
stylesEncoder styles =
    list <| List.map styleEncoder styles


styleEncoder : CssModel -> Value
styleEncoder model =
    object <|
        [ ( "id", int model.id )
        , ( "selector", string model.selector )
        , ( "property", string model.property )
        , ( "value", string model.value )
        , ( "type", string model.type_ )
        , ( "title", string model.title )
        ]
