module Css.View exposing (view)

import Css.Model exposing (..)
import Css.Messages exposing (..)
import Html exposing (Html, ul, li, text)
import Html.Attributes exposing (class)


view : Model -> Html Msg
view model =
    ul [ class "styles__style" ]
        [ text model.title
        ]
