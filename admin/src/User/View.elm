module User.View exposing (view)

import User.Model exposing (..)
import User.Messages exposing (..)
import Html exposing (Html, div, text)


view : Model -> Html Msg
view model =
    div [] [ text model.entry ]
