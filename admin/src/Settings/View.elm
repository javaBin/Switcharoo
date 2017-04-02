module Settings.View exposing (view)

import Settings.Model exposing (..)
import Settings.Messages exposing (..)
import Services.Services
import Styles.View
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


view : Model -> Html Msg
view model =
    div [ class "settings" ]
        [ div [ class "settings__section" ]
            [ Html.map ServicesMsg <| Services.Services.view model.services ]
        , div [ class "settings__section" ]
            [ Html.map StylesMsg <| Styles.View.view model.styles ]
        ]
