module View.Settings exposing (..)

import Html exposing (Html, div, text, ul, li, h2, input, button, span)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick, onInput)
import Models.Model exposing (Model, Setting)
import Messages exposing (Msg(..))
import View.Box


viewSettings : Model -> Html Msg
viewSettings model =
    View.Box.box "Twitter" <|
        div [ class "settings" ]
            [ ul [ class "settings__list" ] <|
                List.map viewSetting model.settings
            , button [ class "button", onClick SaveSettings ] [ text "Save" ]
            ]


viewSetting : Setting -> Html Msg
viewSetting setting =
    li [ class "settings__setting" ]
        [ div [ class "settings__setting-title" ] [ text setting.hint ]
        , input [ type_ "text", value setting.value, onInput <| SettingChanged setting, class "input--box" ] []
        ]
