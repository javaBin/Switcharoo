module Services.Services exposing (..)

import Services.Model exposing (..)
import Services.Messages exposing (..)
import Html exposing (Html, map, ul, h2, text, div)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, list)
import Service.Service
import Service.Model
import Service.Messages


decoder : Decoder (List Service.Model.Model)
decoder =
    list Service.Service.decoder


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SettingMsg setting settingMsg ->
            let
                ( newSettings, newCmds ) =
                    List.unzip (List.map (updateSetting setting settingMsg) model.settings)
            in
                ( { model | settings = newSettings }, Cmd.batch newCmds )

        Settings (Err _) ->
            ( model, Cmd.none )

        Settings (Ok settings) ->
            ( Model settings, Cmd.none )


updateSetting : Service.Model.Model -> Service.Messages.Msg -> Service.Model.Model -> ( Service.Model.Model, Cmd Msg )
updateSetting newModel msg currentModel =
    if newModel.id == currentModel.id then
        let
            ( newSetting, newCmd ) =
                Service.Service.update msg newModel
        in
            ( newSetting, Cmd.map (SettingMsg newSetting) newCmd )
    else
        ( currentModel, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "services" ]
        [ viewSettings model ]


viewSettings : Model -> Html Msg
viewSettings model =
    ul [ class "service-list" ] <|
        List.map
            (\setting -> map (SettingMsg setting) (Service.Service.view setting))
            model.settings
