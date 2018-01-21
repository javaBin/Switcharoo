module View.Login exposing (view)

import Html exposing (Html, div, button, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Models.Model exposing (Model)
import Messages exposing (Msg(..))


view : Model -> Html Msg
view model =
    div [ class "login" ]
        [ button [ class "login__button button", onClick Login ] [ text "Logg inn" ]
        ]
