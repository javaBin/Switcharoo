module Css.View exposing (view)

import Css.Model exposing (..)
import Css.Messages exposing (..)
import Html exposing (Html, ul, li, text, input, button, span)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onInput, onClick)


view : Model -> Html Msg
view model =
    Debug.log (model.value) <|
        li [ class "styles-list__style style" ]
            [ span [ class "style__label" ] [ text model.title ]
            , input [ class "style__input", type_ "color", value model.value, onInput Update ] []
            , button [ class "button style__save", onClick Save ] [ text "Save" ]
            ]
