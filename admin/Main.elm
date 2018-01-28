module Main exposing (..)

import Html exposing (Html, programWithFlags, div)
import Navigation
import Nav.Nav exposing (hashParser, toHash)
import Nav.Model exposing (Page(..))
import Slides.Slides
import Slide.Slide
import Settings.Messages
import Settings.Update
import Settings.View
import Services.Services
import Backend
import Models.Model exposing (Model, Flags, initModel, CssModel, Setting)
import Auth
import Messages exposing (Msg(..), CssMsg(..))
import Decoder exposing (stylesDecoder)
import Task
import Process exposing (sleep)
import Time exposing (millisecond)
import SocketIO
import Popup
import View.Login
import View.LoggedIn
import Decoders.Slide


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        page =
            hashParser location

        cmd =
            if page /= LoggedOut then
                Navigation.newUrl <| toHash page
            else
                Cmd.none
    in
        ( initModel flags page, Cmd.batch [ cmd, SocketIO.connect <| flags.host ++ "/admin" ] )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SlidesMsg msg ->
            let
                ( newSlides, cmd ) =
                    Slides.Slides.update msg model.slides

                mappedCmd =
                    Cmd.map SlidesMsg cmd
            in
                ( { model | slides = newSlides }, mappedCmd )

        SlideMsg slide msg ->
            let
                ( newSlide, newMsg ) =
                    Slide.Slide.update msg slide

                slidesModel =
                    model.slides

                newEditSlide =
                    Maybe.map (\popupState -> { popupState | data = newSlide }) slidesModel.newSlide
            in
                ( { model | slides = { slidesModel | newSlide = newEditSlide } }, Cmd.map (SlideMsg newSlide) newMsg )

        SettingsMsg msg ->
            let
                ( newServices, servicesCmd ) =
                    Settings.Update.update msg model.services
            in
                ( { model | services = newServices }, Cmd.map SettingsMsg servicesCmd )

        Login ->
            ( model, Auth.login () )

        LoginResult userData ->
            let
                cmd =
                    if model.page == LoggedOut then
                        Navigation.newUrl <| toHash SlidesPage
                    else
                        Cmd.none
            in
                ( { model | auth = Auth.LoggedIn userData }, cmd )

        PageChanged page ->
            updatePage page { model | page = page }

        GotStyles (Ok styles) ->
            ( { model | styles = styles }, Cmd.none )

        GotStyles (Err err) ->
            ( model, Cmd.none )

        SaveStyles ->
            ( model, Backend.editStyles model.styles )

        SavedStyles (Ok _) ->
            ( { model | savedSuccessfully = Just True }, disableSavedSuccessfully )

        SavedStyles (Err _) ->
            ( { model | savedSuccessfully = Just False }, disableSavedSuccessfully )

        Css cssModel cssMsg ->
            let
                ( newStyles, newCmds ) =
                    List.unzip <| List.map (findAndUpdateCss cssModel cssMsg) model.styles
            in
                ( { model | styles = newStyles }, Cmd.batch newCmds )

        GetSettings (Ok settings) ->
            ( { model | settings = settings }
            , Cmd.none
            )

        GetSettings (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        SettingChanged setting value ->
            ( { model | settings = List.map (updateSetting setting value) model.settings }
            , Cmd.none
            )

        SaveSettings ->
            ( model, Backend.saveSettings model.settings )

        SettingsSaved (Ok settings) ->
            ( { model | settings = settings, savedSuccessfully = Just True }
            , disableSavedSuccessfully
            )

        SettingsSaved (Err _) ->
            ( { model | savedSuccessfully = Just False }
            , disableSavedSuccessfully
            )

        DisableSavedSuccessfully ->
            ( { model | savedSuccessfully = Nothing }
            , Cmd.none
            )

        WSMessage s ->
            ( { model | connectedClients = Just s }, Cmd.none )

        SlidePopupCancel ->
            let
                slides =
                    model.slides
            in
                ( { model | slides = { slides | newSlide = Nothing } }, Cmd.none )

        SlidePopupSave slide ->
            ( model, Slide.Slide.createOrEditSlide slide.slide SlideSave )

        SlideSave (Ok slide) ->
            let
                slides =
                    model.slides
            in
                ( { model | slides = { slides | newSlide = Nothing } }, Cmd.map SlidesMsg <| Backend.getSlides Decoders.Slide.decoder )

        SlideSave (Err _) ->
            ( model, Cmd.none )

        Ignore ->
            ( model, Cmd.none )


disableSavedSuccessfully : Cmd Msg
disableSavedSuccessfully =
    Task.perform (\_ -> DisableSavedSuccessfully) <| sleep <| 2000 * millisecond


findAndUpdateCss : CssModel -> CssMsg -> CssModel -> ( CssModel, Cmd Msg )
findAndUpdateCss selectedModel msg model =
    if selectedModel.id == model.id then
        updateCss model msg
    else
        ( model, Cmd.none )


updateCss : CssModel -> CssMsg -> ( CssModel, Cmd Msg )
updateCss model msg =
    case msg of
        Update value ->
            ( { model | value = value }, Cmd.none )

        Request _ ->
            ( model, Cmd.none )


updateSetting : Setting -> String -> Setting -> Setting
updateSetting setting value currentModel =
    if setting.id == currentModel.id then
        { setting | value = value }
    else
        setting


updatePage : Page -> Model -> ( Model, Cmd Msg )
updatePage page model =
    case page of
        SlidesPage ->
            ( model, Cmd.map SlidesMsg <| Backend.getSlides Decoders.Slide.decoder )

        ServicesPage ->
            ( model
            , Cmd.batch
                [ Cmd.map SettingsMsg <|
                    Cmd.map Settings.Messages.ServicesMsg <|
                        Backend.getServices Services.Services.decoder
                ]
            )

        SettingsPage ->
            ( model, Backend.getSettings "hack" )

        StylesPage ->
            ( model, Backend.getStyles stylesDecoder )

        LoggedOut ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model.auth of
        Auth.LoggedOut ->
            View.Login.view model

        Auth.LoggedIn _ ->
            View.LoggedIn.view model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Auth.loginResult LoginResult
        , Maybe.withDefault Sub.none <|
            Maybe.map
                (\popupState -> Sub.map (SlideMsg popupState.data) <| Slide.Slide.subscriptions popupState.data)
                model.slides.newSlide
        , SocketIO.onMessage WSMessage
        ]


main : Program Flags Model Msg
main =
    Navigation.programWithFlags
        (PageChanged << hashParser)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
