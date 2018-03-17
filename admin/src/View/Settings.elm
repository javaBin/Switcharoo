module View.Settings exposing (..)

import Html exposing (Html, div, text, ul, li, h2, input, button, span)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick, onInput)
import Models.Model exposing (Model)
import Models.ConferenceModel exposing (ConferenceModel, Setting)
import Messages exposing (ConferenceMsg(..))
import View.Box
import View.Overlay


viewSettings : ConferenceModel -> Html ConferenceMsg
viewSettings model =
    View.Box.container <|
        [ View.Box.box "Twitter" [] <|
            div [ class "settings" ]
                [ ul [ class "settings__list" ] <|
                    List.map viewSetting model.settings
                , button [ class "button", onClick SaveSettings ] [ text "Save" ]
                ]
        , View.Overlay.view model.overlay
        ]


viewSetting : Setting -> Html ConferenceMsg
viewSetting setting =
    li [ class "settings__setting" ]
        [ div [ class "settings__setting-title" ] [ text setting.hint ]
        , input [ type_ "text", value setting.value, onInput <| SettingChanged setting, class "input--box" ] []
        ]
