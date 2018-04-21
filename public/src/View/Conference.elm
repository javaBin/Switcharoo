module View.Conference exposing (view)

import Html exposing (Html, div, map)
import Html.Attributes exposing (class)
import View.Overlay
import Models exposing (Model)
import Messages exposing (Msg(..))
import Models.Slides


view : Model -> Html Msg
view model =
    div [ class "switcharoo" ]
        [ (View.Overlay.view model.overlay)
        , map SlidesMsg (Models.Slides.view model.slides)
        ]
