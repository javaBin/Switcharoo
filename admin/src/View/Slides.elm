module View.Slides exposing (viewSlides)

import Html exposing (Html, map, div, ul, button, i)
import Html.Attributes exposing (class)
import Messages exposing (Msg(..))
import Slides.Slides
import Models.Model
import Models.Slides
import Popup
import View.Slide


viewSlides : Models.Model.Model -> Html Msg
viewSlides model =
    let
        slides =
            List.map (\slide -> map SlidesMsg slide) <| Slides.Slides.view model.slides
    in
        div [ class "slides" ]
            [ Maybe.withDefault (div [] []) <| Maybe.map viewEdit model.slides.newSlide
            , ul [ class "slides__slides" ] slides
            , button
                [ class "slides__settings" ]
                [ i [ class "icon-settings" ] [] ]
            ]


viewEdit : Popup.State Models.Slides.SlideModel -> Html Msg
viewEdit state =
    Popup.view
        (Popup.config
            (SlidePopupSave state.data)
            Ignore
            SlidePopupCancel
            state.title
            (View.Slide.edit state.data)
        )
