module View.Overlay exposing (view)

import Messages exposing (Msg)
import Models exposing (Overlay, Slides, SlideWrapper(..))
import Html exposing (Html, div, img)
import Html.Attributes exposing (class, style, src)
import List.Zipper exposing (current)


view : Maybe Overlay -> Slides -> Html Msg
view maybeOverlay slides =
    case maybeOverlay of
        Nothing ->
            div [] []

        Just overlay ->
            viewOverlay overlay slides


viewOverlay : Overlay -> Slides -> Html Msg
viewOverlay overlay slides =
    img
        [ class <| "switcharoo__overlay " ++ overlay.placement
        , style [ ( "width", overlay.width ), ( "height", overlay.height ), ( "opacity", overlayOpacity slides ) ]
        , src overlay.image
        ]
        []


overlayOpacity : Slides -> String
overlayOpacity slides =
    let
        slide =
            current slides.slides
    in
        case slide of
            TweetsWrapper _ ->
                "0"

            _ ->
                "1"
