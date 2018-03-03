module View.Overlay exposing (view)

import Messages exposing (Msg)
import Models exposing (Overlay)
import Html exposing (Html, div, img)
import Html.Attributes exposing (class, style, src)


view : Maybe Overlay -> Html Msg
view maybeOverlay =
    case maybeOverlay of
        Nothing ->
            div [] []

        Just overlay ->
            viewOverlay overlay


viewOverlay : Overlay -> Html Msg
viewOverlay overlay =
    img
        [ class <| "switcharoo__overlay " ++ overlay.placement
        , style [ ( "width", overlay.width ), ( "height", overlay.height ) ]
        , src overlay.image
        ]
        []
