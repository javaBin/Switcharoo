module Settings.Settings exposing (..)

import Settings.Model exposing (..)
import Settings.Messages exposing (..)
import Html exposing (Html, map, ul)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, list)
import Setting


decoder : Decoder (List Setting.Model)
decoder =
    list Setting.decoder


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


updateSetting : Setting.Model -> Setting.Msg -> Setting.Model -> ( Setting.Model, Cmd Msg )
updateSetting newModel msg currentModel =
    if newModel.id == currentModel.id then
        let
            ( newSetting, newCmd ) =
                Setting.update msg newModel
        in
            ( newSetting, Cmd.map (SettingMsg newSetting) newCmd )
    else
        ( currentModel, Cmd.none )


view : Model -> Html Msg
view model =
    ul [ class "settings" ] <|
        List.map (\setting -> map (SettingMsg setting) (Setting.view setting)) model.settings
