module View.LoggedIn exposing (view)

import Html exposing (Html, map, div, text, li, i, ul, button, a, img)
import Html.Attributes exposing (class, classList, href, src)
import Models.Model exposing (Model)
import Models.ConferenceModel exposing (ConferenceModel)
import Messages exposing (ConferenceMsg(..))
import View.Settings exposing (viewSettings)
import View.Styles exposing (viewStyles)
import View.Slides exposing (viewSlides)
import Slides.Slides
import Nav.Nav exposing (routeToString)
import Nav.Model exposing (Page(..), ConferencePage(..))
import Icons


view : ConferenceModel -> Html ConferenceMsg
view model =
    div [ class "app" ]
        [ viewMain model
        ]


pageTitle : ConferencePage -> String
pageTitle page =
    case page of
        SlidesPage ->
            "Slides"

        SettingsPage ->
            "Settings"

        StylesPage ->
            "Styles"


viewMain : ConferenceModel -> Html ConferenceMsg
viewMain model =
    let
        page =
            case model.page of
                SlidesPage ->
                    viewSlides model

                SettingsPage ->
                    viewSettings model

                StylesPage ->
                    viewStyles model
    in
        div [ class "app__main" ]
            [ viewSidebar model
            , viewContent model page
            ]


viewSidebar : ConferenceModel -> Html ConferenceMsg
viewSidebar model =
    div [ class "app__sidebar sidebar" ]
        [ a [ href <| routeToString Nav.Model.ConferencesPage ]
            [ img [ src "logo.svg", class "sidebar__logo" ] [] ]
        , div [ class "sidebar__conference" ] [ text model.conference.name ]
        , ul [ class "sidebar__menu" ]
            [ viewLink model <| SlidesPage
            , viewLink model <| SettingsPage
            , viewLink model <| StylesPage
            ]
        , viewBackToConferences
        ]


viewContent : ConferenceModel -> Html ConferenceMsg -> Html ConferenceMsg
viewContent model page =
    div [ class "app__content" ]
        [ div [ class "app__page-content" ] [ page ]
        , viewMessageArea model
        ]


viewLink : ConferenceModel -> ConferencePage -> Html ConferenceMsg
viewLink model page =
    li [ classList [ ( "sidebar__menu-link", True ), ( "sidebar__menu-link--active", model.page == page ) ] ]
        [ a
            [ href <| routeToString <| Nav.Model.ConferencePage model.conference.id page
            , classList [ ( "sidebar__link", True ), ( "sidebar__link--active", model.page == page ) ]
            ]
            [ icon page
            , text <| pageTitle page
            ]
        ]


viewBackToConferences : Html ConferenceMsg
viewBackToConferences =
    div [ class "sidebar__menu-link" ]
        [ a
            [ href <| routeToString Nav.Model.ConferencesPage
            , class "sidebar__conferences sidebar__link"
            ]
            [ Icons.keyboardArrowLeftIcon
            , text "Conferences"
            ]
        ]


icon : ConferencePage -> Html msg
icon page =
    case page of
        SlidesPage ->
            Icons.slidesIcon

        SettingsPage ->
            Icons.settingsIcon

        StylesPage ->
            Icons.brushIcon


viewMessageArea : ConferenceModel -> Html ConferenceMsg
viewMessageArea model =
    case model.savedSuccessfully of
        Nothing ->
            div [ class "app__message-area message-area" ]
                []

        Just success ->
            div
                [ classList
                    [ ( "app__message-area message-area", True )
                    , ( "message-area--success", success )
                    , ( "message-area--failure", not success )
                    ]
                ]
                [ text <|
                    if success then
                        "Saved"
                    else
                        "Could not save"
                ]
