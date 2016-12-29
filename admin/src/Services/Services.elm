module Services.Services exposing (..)

import Services.Model exposing (..)
import Services.Messages exposing (..)
import Html exposing (Html, map, ul)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, list)
import Service


decoder : Decoder (List Service.Model)
decoder =
    list Service.decoder


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


updateSetting : Service.Model -> Service.Msg -> Service.Model -> ( Service.Model, Cmd Msg )
updateSetting newModel msg currentModel =
    if newModel.id == currentModel.id then
        let
            ( newSetting, newCmd ) =
                Service.update msg newModel
        in
            ( newSetting, Cmd.map (SettingMsg newSetting) newCmd )
    else
        ( currentModel, Cmd.none )


view : Model -> Html Msg
view model =
    ul [ class "settings" ] <|
        List.map (\setting -> map (SettingMsg setting) (Service.view setting)) model.settings
