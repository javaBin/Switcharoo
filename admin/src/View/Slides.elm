module View.Slides exposing (viewSlides)

import Html exposing (Html, map, div, ul, button, i, text)
import Html.Attributes exposing (class)
import Messages exposing (ConferenceMsg(..))
import Slides.Slides
import Models.ConferenceModel exposing (ConferenceModel)
import Models.Slides
import Popup
import View.Slide
import Services.Services
import View.Box


viewSlides : ConferenceModel -> Html ConferenceMsg
viewSlides model =
    let
        slides =
            List.map (\slide -> map SlidesMsg slide) <| Slides.Slides.view model.slides
    in
        View.Box.container
            [ View.Box.box "Regular slides" <|
                div [ class "slides" ]
                    [ Maybe.withDefault (div [] []) <| Maybe.map viewEdit model.slides.newSlide
                    , ul [ class "slides__slides" ] slides
                    ]
            , View.Box.box "Special slides" <|
                Html.map ServicesMsg <|
                    Services.Services.view model.services
            ]


viewEdit : Popup.State Models.Slides.SlideModel -> Html ConferenceMsg
viewEdit state =
    Popup.view
        (Popup.config
            (SlidePopupSave state.data)
            Ignore
            SlidePopupCancel
            state.title
            (View.Slide.edit state.data)
        )
