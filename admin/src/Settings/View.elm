module Settings.View exposing (view)

import Settings.Model exposing (..)
import Settings.Messages exposing (..)
import Services.Services
import Styles.View
import Html exposing (Html, div, text)


view : Model -> Html Msg
view model =
    div []
        [ Html.map ServicesMsg <| Services.Services.view model.services
        , Html.map StylesMsg <| Styles.View.view model.styles
        ]
