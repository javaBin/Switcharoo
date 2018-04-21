module Main exposing (..)

import Html exposing (Html, programWithFlags, div)
import Navigation
import Nav.Nav exposing (hashParser, routeToString)
import Nav.Model exposing (Page(..), ConferencePage(..))
import Slides.Slides
import Slide.Slide
import Services.Services
import Backend
import Models.Model exposing (Model, Flags, initModel)
import Models.ConferenceModel exposing (ConferenceModel, CssModel, Setting)
import Models.Conference exposing (Conference)
import Models.Overlay exposing (Overlay, Placement)
import Auth
import Messages exposing (Msg(..), ConferenceMsg(..), CssMsg(..))
import Task
import Process exposing (sleep)
import Time exposing (millisecond)
import View.Login
import View.LoggedIn
import View.Conferences
import Ports exposing (FileData, fileSelected, fileUploadSucceeded, fileUploadFailed)
import WebSocket
import Ws


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        page =
            hashParser location

        cmd =
            if page /= LoggedOutPage then
                Navigation.newUrl <| routeToString page
            else
                Cmd.none
    in
        ( initModel flags page, cmd )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ConferenceMsg conferenceMsg ->
            let
                ( conferenceModel, cmd ) =
                    Maybe.withDefault ( Nothing, Cmd.none ) <| Maybe.map (Tuple.mapFirst Just) <| Maybe.map (\c -> conferenceUpdate model.flags conferenceMsg c) model.selection
            in
                ( { model | selection = conferenceModel }, Cmd.map ConferenceMsg cmd )

        LoginResult userData ->
            let
                cmd =
                    if model.page == LoggedOutPage then
                        Navigation.newUrl <| routeToString ConferencesPage
                    else
                        Cmd.none
            in
                ( { model | auth = Auth.LoggedIn userData }, cmd )

        Login ->
            ( model, Auth.login () )

        PageChanged page ->
            updatePage page { model | page = page }

        Conferences (Ok conferences) ->
            ( { model | conferences = conferences }, Cmd.none )

        Conferences (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        CreateConference ->
            ( model, Task.attempt Conferences <| Task.andThen (\c -> Backend.getConferencesTask "hack") (Backend.createConference <| Conference 0 model.conferenceName) )

        GetConferences ->
            ( model, Backend.getConferences "hack" )

        ConferenceName name ->
            ( { model | conferenceName = name }, Cmd.none )


conferenceUpdate : Flags -> ConferenceMsg -> ConferenceModel -> ( ConferenceModel, Cmd ConferenceMsg )
conferenceUpdate flags msg model =
    case msg of
        GotConference (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        GotConference (Ok conference) ->
            ( { model | conference = conference }, Cmd.none )

        SlidesMsg msg ->
            let
                ( newSlides, cmd ) =
                    Slides.Slides.update model.conference msg model.slides

                mappedCmd =
                    Cmd.map SlidesMsg cmd
            in
                ( { model | slides = newSlides }, mappedCmd )

        ServicesMsg msg ->
            let
                ( newServices, servicesCmd ) =
                    Services.Services.update model.conference msg model.services
            in
                ( { model | services = newServices }, Cmd.map ServicesMsg servicesCmd )

        GotStyles (Ok styles) ->
            ( { model | styles = styles }, Cmd.none )

        GotStyles (Err err) ->
            ( model, Cmd.none )

        SaveStyles ->
            ( model, Backend.editStyles model.conference model.styles )

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
            ( model, Backend.saveSettings model.conference model.settings )

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
            parseWebsocketMessage flags model s

        SlidePopupCancel ->
            let
                slides =
                    model.slides
            in
                ( { model | slides = { slides | newSlide = Nothing } }, Cmd.none )

        SlidePopupSave slide ->
            ( model, Slide.Slide.createOrEditSlide model.conference slide.slide SlideSave )

        SlideSave (Ok slide) ->
            let
                slides =
                    model.slides
            in
                ( { model | slides = { slides | newSlide = Nothing } }
                , Cmd.map SlidesMsg <| Backend.getSlides model.conference
                )

        SlideSave (Err _) ->
            ( model, Cmd.none )

        Ignore ->
            ( model, Cmd.none )

        OverlayEnable enabled ->
            ( { model | overlay = updateEnable model.overlay enabled }, Cmd.none )

        OverlayPlacement placement ->
            ( { model | overlay = updatePlacement model.overlay placement }, Cmd.none )

        OverlayWidth width ->
            ( { model | overlay = updateWidth model.overlay width }, Cmd.none )

        OverlayHeight height ->
            ( { model | overlay = updateHeight model.overlay height }, Cmd.none )

        OverlayFileSelected ->
            ( model, fileSelected "overlay-file" )

        OverlayFileUploaded file ->
            ( { model | overlay = updateImage model.overlay file }, Cmd.none )

        OverlayFileUploadFailed error ->
            Debug.log (toString error) ( model, Cmd.none )

        OverlaySave ->
            ( model, Backend.saveOverlay model.conference model.overlay )

        OverlaySaved (Ok overlay) ->
            ( { model | overlay = overlay }, Cmd.none )

        OverlaySaved (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )


parseWebsocketMessage : Flags -> ConferenceModel -> Ws.Command -> ( ConferenceModel, Cmd ConferenceMsg )
parseWebsocketMessage flags model command =
    case command of
        Ws.Welcome ->
            ( model, WebSocket.send (wsUrl flags) "REGISTER:ADMIN" )

        Ws.ClientCount count ->
            ( { model | connectedClients = count }, Cmd.none )

        Ws.Illegal frame ->
            Debug.log ("Illegal frame: " ++ frame) ( model, Cmd.none )

        Ws.Unknown command ->
            Debug.log ("Unknown command: " ++ command) ( model, Cmd.none )


updateEnable : Overlay -> Bool -> Overlay
updateEnable overlay enabled =
    { overlay | enabled = enabled }


updateImage : Overlay -> FileData -> Overlay
updateImage overlay file =
    { overlay | image = file.location }


updatePlacement : Overlay -> Placement -> Overlay
updatePlacement overlay placement =
    { overlay | placement = placement }


updateWidth : Overlay -> String -> Overlay
updateWidth overlay width =
    { overlay | width = width }


updateHeight : Overlay -> String -> Overlay
updateHeight overlay height =
    { overlay | height = height }


updateOverlay : Overlay -> (Overlay -> Overlay) -> Overlay
updateOverlay overlay updateFn =
    updateFn overlay


disableSavedSuccessfully : Cmd ConferenceMsg
disableSavedSuccessfully =
    Task.perform (\_ -> DisableSavedSuccessfully) <| sleep <| 2000 * millisecond


findAndUpdateCss : CssModel -> CssMsg -> CssModel -> ( CssModel, Cmd ConferenceMsg )
findAndUpdateCss selectedModel msg model =
    if selectedModel.id == model.id then
        updateCss model msg
    else
        ( model, Cmd.none )


updateCss : CssModel -> CssMsg -> ( CssModel, Cmd ConferenceMsg )
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
        LoggedOutPage ->
            ( model, Cmd.none )

        ConferencesPage ->
            ( { model | selection = Nothing }, Backend.getConferences "hack" )

        ConferencePage id conferencePage ->
            let
                conference =
                    Maybe.withDefault
                        (Models.ConferenceModel.initConferenceModel conferencePage <|
                            Models.Conference.Conference id ""
                        )
                        model.selection

                updatedConference =
                    { conference | page = conferencePage }

                cmd =
                    updateConferencePage conference.conference conferencePage

                conferenceRequest =
                    case model.selection of
                        Nothing ->
                            Cmd.map ConferenceMsg <| Backend.getConference id

                        _ ->
                            Cmd.none
            in
                ( { model | selection = Just updatedConference }, Cmd.batch [ conferenceRequest, Cmd.map ConferenceMsg cmd ] )


updateConferencePage : Conference -> ConferencePage -> Cmd ConferenceMsg
updateConferencePage conference page =
    case page of
        SlidesPage ->
            Cmd.batch
                [ Cmd.map SlidesMsg <| Backend.getSlides conference
                , Cmd.map ServicesMsg <| Backend.getServices conference
                ]

        SettingsPage ->
            Cmd.batch
                [ Backend.getSettings conference
                , Backend.getOverlay conference
                ]

        StylesPage ->
            Backend.getStyles conference


view : Model -> Html Msg
view model =
    case model.auth of
        Auth.LoggedOut ->
            View.Login.view model

        Auth.LoggedIn _ ->
            case model.selection of
                Nothing ->
                    View.Conferences.view model

                Just conference ->
                    Html.map ConferenceMsg <| View.LoggedIn.view conference


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        confSub =
            case model.selection of
                Nothing ->
                    Sub.none

                Just conf ->
                    Sub.map ConferenceMsg <| conferenceSubscriptions model conf
    in
        Sub.batch
            [ Auth.loginResult LoginResult
            , confSub
            ]


conferenceSubscriptions : Model -> ConferenceModel -> Sub ConferenceMsg
conferenceSubscriptions model conference =
    Sub.batch
        [ Maybe.withDefault Sub.none <|
            Maybe.map
                (\popupState -> Sub.map SlidesMsg <| Slide.Slide.subscriptions popupState.data)
                conference.slides.newSlide
        , WebSocket.listen (wsUrl model.flags) (\s -> WSMessage <| Ws.parse s)
        , fileUploadSucceeded OverlayFileUploaded
        , fileUploadFailed OverlayFileUploadFailed
        ]


wsUrl : Flags -> String
wsUrl flags =
    "ws://" ++ flags.host ++ "/websocket"


main : Program Flags Model Msg
main =
    Navigation.programWithFlags
        (PageChanged << hashParser)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
