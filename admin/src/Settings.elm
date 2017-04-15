module Settings exposing (..)

import Html exposing (Html, div, text, ul, li, h2, input, button)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick, onInput)
import Model exposing (Model, SettingModel)
import Messages exposing (Msg(..))


viewSettings : Model -> Html Msg
viewSettings model =
    div [ class "settings" ]
        [ h2 [] [ text "Settings" ]
        , ul [ class "settings" ] <|
            List.map viewSetting model.settings
        , button [ class "button", onClick SaveSettings ] [ text "Save" ]
        ]


viewSetting : SettingModel -> Html Msg
viewSetting setting =
    li [ class "setting" ]
        [ text setting.hint
        , input [ type_ "text", value setting.value, onInput <| SettingChanged setting ] []
        ]
