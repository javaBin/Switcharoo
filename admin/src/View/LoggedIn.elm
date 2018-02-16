module View.LoggedIn exposing (view)

import Html exposing (Html, map, div, text, li, i, ul, button, a)
import Html.Attributes exposing (class, classList, href)
import Models.Model exposing (Model)
import Messages exposing (Msg(..))
import Services.Services
import View.Settings exposing (viewSettings)
import View.Styles exposing (viewStyles)
import View.Slides exposing (viewSlides)
import Slides.Slides
import Nav.Nav exposing (toHash)
import Nav.Model exposing (Page(..))


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ viewMain model
        ]


pageTitle : Page -> String
pageTitle page =
    case page of
        LoggedOut ->
            "Logged out"

        SlidesPage ->
            "Slides"

        SettingsPage ->
            "Settings"

        StylesPage ->
            "Styles"


viewMain : Model -> Html Msg
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

                _ ->
                    div [] []
    in
        div [ class "app__main" ]
            [ viewSidebar model
            , viewContent model page
            ]


viewSidebar : Model -> Html Msg
viewSidebar model =
    div [ class "app__sidebar sidebar" ]
        [ text "Switcharoo"
        , ul [ class "sidebar__menu" ]
            [ viewLink model SlidesPage
            , viewLink model SettingsPage
            , viewLink model StylesPage
            ]
        ]


viewContent : Model -> Html Msg -> Html Msg
viewContent model page =
    div [ class "app__content" ]
        [ div [ class "app__page-content" ] [ page ]
        , viewMessageArea model
        ]


viewLink : Model -> Page -> Html Msg
viewLink model page =
    li [ classList [ ( "sidebar__menu-link", True ), ( "sidebar__menu-link--active", model.page == page ) ] ]
        [ a
            [ href <| toHash page
            , classList [ ( "sidebar__link", True ), ( "sidebar__link--active", model.page == page ) ]
            ]
            [ i [ class <| linkText page ] [ text "" ]
            , text <| pageTitle page
            ]
        ]


linkText : Page -> String
linkText page =
    "sidebar__icon "
        ++ case page of
            SlidesPage ->
                "icon-screen-desktop"

            SettingsPage ->
                "icon-settings"

            StylesPage ->
                "icon-magic-wand"

            _ ->
                ""


viewMessageArea : Model -> Html Msg
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


viewServices : Model -> Html Msg
viewServices model =
    map ServicesMsg <| Services.Services.view model.services
