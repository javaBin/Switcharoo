module View.Slide exposing (edit)

import Html exposing (Html, div, button, text, input, ul, li, textarea)
import Html.Attributes exposing (class, classList, style, placeholder, value, type_, id, disabled)
import Html.Events exposing (onClick, onInput, on)
import Json.Decode exposing (succeed)
import Models.Slides
import Events exposing (onClickStopPropagation)
import Messages exposing (ConferenceMsg(..))
import Slides.Messages exposing (Msg)
import Icons


edit : Models.Slides.SlideModel -> Html ConferenceMsg
edit slide =
    if slide.slide.type_ == "text" then
        editText slide
    else
        editMedia slide


editMedia : Models.Slides.SlideModel -> Html ConferenceMsg
editMedia model =
    div []
        [ tabsView model True False
        , div [ class "modal__slide" ]
            [ input
                [ type_ "text"
                , class "input modal__index"
                , onInput <| (\name -> SlidesMsg <| Slides.Messages.Name model name)
                , value model.slide.name
                , placeholder "Name"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__index"
                , onInput <| (\index -> SlidesMsg <| Slides.Messages.Index model index)
                , value <| toString model.slide.index
                , placeholder "Index"
                ]
                []
            , input
                [ type_ "file"
                , id "MediaInputId"
                , on "change" (succeed <| SlidesMsg <| Slides.Messages.FileSelected model)
                ]
                []
            , selectColorView model
            ]
        ]


editText : Models.Slides.SlideModel -> Html ConferenceMsg
editText model =
    div []
        [ tabsView model False True
        , div [ class "modal__slide" ]
            [ input
                [ type_ "text"
                , class "input modal__index"
                , onInput (\name -> SlidesMsg <| Slides.Messages.Name model name)
                , value model.slide.name
                , placeholder "Name"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__index"
                , onInput (\index -> SlidesMsg <| Slides.Messages.Index model index)
                , value <| toString model.slide.index
                , placeholder "Index"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__title"
                , onInput (\title -> SlidesMsg <| Slides.Messages.Title model title)
                , value model.slide.title
                , placeholder "Title"
                ]
                []
            , textarea
                [ onInput (\body -> SlidesMsg <| Slides.Messages.Body model body)
                , class "input modal__body"
                , value model.slide.body
                , placeholder "Body"
                ]
                []
            , selectColorView model
            ]
        ]


tabsView : Models.Slides.SlideModel -> Bool -> Bool -> Html ConferenceMsg
tabsView model mediaSelected textSelected =
    div [ class "tabs" ]
        [ button
            [ classList [ ( "tabs__tab", True ), ( "tabs__tab--active", mediaSelected ) ]
            , onClickStopPropagation <| SlidesMsg <| Slides.Messages.MediaSlide model
            , disabled mediaSelected
            ]
            [ Icons.image, text "Media" ]
        , button
            [ classList [ ( "tabs__tab", True ), ( "tabs__tab--active", textSelected ) ]
            , onClickStopPropagation <| SlidesMsg <| Slides.Messages.TextSlide model
            , disabled textSelected
            ]
            [ Icons.formatAlignLeft, text "Text" ]
        ]


selectColorView : Models.Slides.SlideModel -> Html ConferenceMsg
selectColorView model =
    div []
        [ ul [ class "modal__color" ] <|
            List.map (singleColorView model) [ Nothing, Just "#0078c9", Just "#ef8717", Just "#58836a", Just "#874b85" ]
        ]


singleColorView : Models.Slides.SlideModel -> Maybe String -> Html ConferenceMsg
singleColorView model color =
    let
        currentColor =
            Maybe.withDefault "#ffffff" color

        selectedColor =
            model.slide.color == color
    in
        li [ class "modal__color-item" ]
            [ button
                [ classList [ ( "color-button", True ), ( "color-button--selected", selectedColor ) ]
                , style [ ( "background", currentColor ) ]
                , onClick <| SlidesMsg <| Slides.Messages.Color model color
                ]
                []
            ]
