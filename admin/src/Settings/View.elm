module Settings.View exposing (view)

import Settings.Model exposing (..)
import Settings.Messages exposing (..)
import Html exposing (Html, div, text)


view : Model -> Html Msg
view model =
    div [] [ text "Settings" ]
