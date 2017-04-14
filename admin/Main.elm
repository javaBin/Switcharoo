module Main exposing (..)

import Html exposing (Html, programWithFlags, map, div, button, text, ul, li, a, h1, i)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Navigation
import Nav.Nav exposing (hashParser, toHash)
import Nav.Model exposing (Page(..))
import Slides.Slides
import Settings.Messages
import Settings.Update
import Settings.View
import Services.Services
import Backend
import Model exposing (Model, Flags, initModel, CssModel)
import Auth
import Messages exposing (Msg(..), CssMsg(..))
import Styles exposing (viewStyles)
import Decoder exposing (stylesDecoder)


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

        GotStyles (Ok styles) ->
            ( { model | styles = styles }, Cmd.none )

        GotStyles (Err err) ->
            ( model, Cmd.none )

        Css cssModel cssMsg ->
            let
                ( newStyles, newCmds ) =
                    List.unzip <| List.map (findAndUpdateCss cssModel cssMsg) model.styles
            in
                ( { model | styles = newStyles }, Cmd.batch newCmds )


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

        Save ->
            ( model, Backend.editStyle model )

        Request _ ->
            ( model, Cmd.none )


updatePage : Page -> Model -> ( Model, Cmd Msg )
updatePage page model =
    case page of
        SlidesPage ->
            ( model, Cmd.map SlidesMsg <| Backend.getSlides Slides.Slides.decoder )

        ServicesPage ->
            ( model
            , Cmd.batch
                [ Cmd.map SettingsMsg <|
                    Cmd.map Settings.Messages.ServicesMsg <|
                        Backend.getServices Services.Services.decoder
                ]
            )

        StylesPage ->
            ( model, Backend.getStyles stylesDecoder )

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

        ServicesPage ->
            "icon-wrench"

        StylesPage ->
            "icon-magic-wand"

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
            , viewLink model ServicesPage
            , viewLink model StylesPage
            ]
        ]


viewMain : Model -> Html Msg
viewMain model =
    let
        content =
            case model.page of
                SlidesPage ->
                    viewSlides model

                ServicesPage ->
                    viewSettings model

                StylesPage ->
                    viewStyles model

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
