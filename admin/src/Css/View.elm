module Css.View exposing (view)

import Css.Model exposing (..)
import Css.Messages exposing (..)
import Html exposing (Html, ul, li, text, input, button)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onInput, onClick)


view : Model -> Html Msg
view model =
    li [ class "styles-list__style" ]
        [ text model.title
        , input [ type_ "text", value model.value, onInput Update ] []
        , button [ onClick Save ] [ text "Update" ]
        ]
