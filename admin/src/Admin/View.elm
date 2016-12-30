module Admin.View exposing (view)

import Admin.Model exposing (..)
import Admin.Messages exposing (..)
import Slides.Slides
import Settings.View
import Html exposing (Html, div, text, map, h1, ul)
import Html.Attributes exposing (class)
import Nav.Model exposing (Page(..))


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ viewSidebar model
        , viewMain model
        ]


viewSidebar : Model -> Html Msg
viewSidebar model =
    div [ class "app__sidebar" ]
        [ h1 [] [ text "Switcharoo" ]
        ]


viewMain : Model -> Html Msg
viewMain model =
    case model.page of
        SlidesPage ->
            viewSlides model

        SettingsPage ->
            viewSettings model


viewSlides : Model -> Html Msg
viewSlides model =
    let
        slides =
            List.map (\slide -> map SlideList slide) <| Slides.Slides.view model.slides
    in
        ul [ class "slides" ] slides


viewSettings : Model -> Html Msg
viewSettings model =
    map SettingsMsg <| Settings.View.view model.settings



-- let
--     slides =
--     settings =
-- in
--     div []
--         [ h1 [] [ text "Switcharoo" ]
--         , settings
--         , ul [ class "slides" ] <|
--             slides
--         ]
