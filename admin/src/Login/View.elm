module Login.View exposing (view)

import Login.Model exposing (..)
import Login.Messages exposing (..)
import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class)


view : Model -> Html Msg
view model =
    div [ class "login" ]
        [ button [] [ text "Logg inn" ] ]
