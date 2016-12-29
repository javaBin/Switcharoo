module Admin.View exposing (view)

import Admin.Model exposing (..)
import Admin.Messages exposing (..)
import Slides.Slides
import Services.Services
import Html exposing (Html, div, text, map, h1, ul)
import Html.Attributes exposing (class)


view : Model -> Html Msg
view model =
    let
        slides =
            List.map (\slide -> map SlideList slide) <| Slides.Slides.view model.slides

        settings =
            map SettingsMsg <| Services.Services.view model.settings
    in
        div []
            [ h1 [] [ text "Switcharoo" ]
            , settings
            , ul [ class "slides" ] <|
                slides
            ]
