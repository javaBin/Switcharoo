module Main exposing (..)

import Html exposing (Html, programWithFlags, map, div, button, text, ul, li, a, h1, i)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Navigation
import Nav.Nav exposing (hashParser, toHash)
import Nav.Model exposing (Page(..))
import Slides.Model
import Slides.Messages
import Slides.Slides
import Settings.Model
import Settings.Messages
import Settings.Update
import Settings.View
import Services.Services
import Styles.Decoder
import Backend
import Auth


type alias Flags =
    { loggedIn : Bool
    }


type alias Model =
    { slides : Slides.Model.Model
    , settings : Settings.Model.Model
    , auth : Auth.AuthStatus
    , flags : Flags
    , page : Nav.Model.Page
    }


initModel : Flags -> Page -> Model
initModel flags page =
    Model Slides.Model.init
        Settings.Model.initModel
        Auth.LoggedOut
        flags
        page


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
        ( initModel flags page, cmd )


type Msg
    = Login
    | LoginResult Auth.UserData
    | SlidesMsg Slides.Messages.Msg
    | SettingsMsg Settings.Messages.Msg
    | PageChanged Page


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

        SettingsMsg msg ->
            let
                ( newSettings, settingsCmd ) =
                    Settings.Update.update msg model.settings
            in
                ( { model | settings = newSettings }, Cmd.map SettingsMsg settingsCmd )

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


updatePage : Page -> Model -> ( Model, Cmd Msg )
updatePage page model =
    case page of
        SlidesPage ->
            ( model, Cmd.map SlidesMsg <| Backend.getSlides Slides.Slides.decoder )

        SettingsPage ->
            ( model
            , Cmd.batch
                [ Cmd.map SettingsMsg <|
                    Cmd.map Settings.Messages.ServicesMsg <|
                        Backend.getSettings Services.Services.decoder
                , Cmd.map SettingsMsg <|
                    Cmd.map Settings.Messages.StylesMsg <|
                        Backend.getStyles Styles.Decoder.decoder
                ]
            )

        LoggedOut ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model.auth of
        Auth.LoggedOut ->
            loginView model

        Auth.LoggedIn _ ->
            loggedInView model


loginView : Model -> Html Msg
loginView model =
    div [ class "login" ]
        [ button [ class "login__button button", onClick Login ] [ text "Logg inn" ]
        ]


loggedInView : Model -> Html Msg
loggedInView model =
    div [ class "app" ]
        [ viewSidebar model
        , viewMain model
        ]


linkText : Page -> String
linkText page =
    case page of
        SlidesPage ->
            "icon-screen-desktop"

        SettingsPage ->
            "icon-settings"

        _ ->
            ""


viewLink : Model -> Page -> Html Msg
viewLink model page =
    let
        linkClass =
            if model.page == page then
                "sidebar__link sidebar__link--active"
            else
                "sidebar__link"
    in
        li [ class "sidebar__menu-link" ]
            [ a [ href <| toHash page, class linkClass ]
                [ i [ class <| linkText page ] [ text "" ] ]
            ]


viewSidebar : Model -> Html Msg
viewSidebar model =
    div [ class "app__sidebar sidebar" ]
        [ div [ class "app__logo" ] [ text "S" ]
        , ul [ class "sidebar__menu" ]
            [ viewLink model SlidesPage
            , viewLink model SettingsPage
            ]
        ]


viewMain : Model -> Html Msg
viewMain model =
    let
        content =
            case model.page of
                SlidesPage ->
                    viewSlides model

                SettingsPage ->
                    viewSettings model

                _ ->
                    div [] []
    in
        div [ class "app__main" ]
            [ div [ class "app__content" ]
                [ content ]
            ]


viewSlides : Model -> Html Msg
viewSlides model =
    let
        slides =
            List.map (\slide -> map SlidesMsg slide) <| Slides.Slides.view model.slides
    in
        ul [ class "slides" ] slides


viewSettings : Model -> Html Msg
viewSettings model =
    map SettingsMsg <| Settings.View.view model.settings


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        -- [ Sub.map AdminMsg <| Admin.Subscriptions.subscriptions model.admin
        [ Auth.loginResult LoginResult
        , Sub.map SlidesMsg <| Slides.Slides.subscriptions model.slides
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
