module View.Slide exposing (edit)

import Html exposing (Html, div, button, text, input, ul, li, textarea)
import Html.Attributes exposing (class, classList, style, placeholder, value, type_, id, disabled)
import Html.Events exposing (onClick, onInput, on)
import Json.Decode exposing (succeed)
import Models.Slides
import Events exposing (onClickStopPropagation)
import Messages exposing (Msg(..))
import Slide.Messages


edit : Models.Slides.SlideModel -> Html Msg
edit slide =
    if slide.slide.type_ == "text" then
        editText slide
    else
        editMedia slide


editMedia : Models.Slides.SlideModel -> Html Msg
editMedia model =
    div []
        [ div [ class "tabs" ]
            [ button
                [ class "tabs__tab tabs__tab--active"
                , disabled True
                ]
                [ text "Media" ]
            , button
                [ class "tabs__tab"
                , onClickStopPropagation <| SlideMsg model Slide.Messages.TextSlide
                ]
                [ text "Text" ]
            ]
        , div [ class "modal__slide" ]
            [ input
                [ type_ "text"
                , class "input modal__index"
                , onInput <| (\name -> SlideMsg model (Slide.Messages.Name name))
                , value model.slide.name
                , placeholder "Name"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__index"
                , onInput <| (\index -> SlideMsg model (Slide.Messages.Index index))
                , value <| toString model.slide.index
                , placeholder "Index"
                ]
                []
            , input
                [ type_ "file"
                , id "MediaInputId"
                , on "change" (succeed <| SlideMsg model Slide.Messages.FileSelected)
                ]
                []
            , selectColorView model
            ]
        ]


editText : Models.Slides.SlideModel -> Html Msg
editText model =
    div []
        [ div [ class "tabs" ]
            [ button
                [ class "tabs__tab"
                , onClickStopPropagation <| SlideMsg model Slide.Messages.MediaSlide
                ]
                [ text "Media" ]
            , button
                [ class "tabs__tab tabs__tab--active"
                , disabled True
                ]
                [ text "Text" ]
            ]
        , div [ class "modal__slide" ]
            [ input
                [ type_ "text"
                , class "input modal__index"
                , onInput (\name -> SlideMsg model (Slide.Messages.Name name))
                , value model.slide.name
                , placeholder "Name"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__index"
                , onInput (\index -> SlideMsg model (Slide.Messages.Index index))
                , value <| toString model.slide.index
                , placeholder "Index"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__title"
                , onInput (\title -> SlideMsg model (Slide.Messages.Title title))
                , value model.slide.title
                , placeholder "Title"
                ]
                []
            , textarea
                [ onInput (\body -> SlideMsg model (Slide.Messages.Body body))
                , class "input modal__body"
                , value model.slide.body
                , placeholder "Body"
                ]
                []
            , selectColorView model
            ]
        ]


selectColorView : Models.Slides.SlideModel -> Html Msg
selectColorView model =
    div []
        [ ul [ class "modal__color" ] <|
            List.map (singleColorView model) [ Nothing, Just "#0078c9", Just "#ef8717", Just "#58836a", Just "#874b85" ]
        ]


singleColorView : Models.Slides.SlideModel -> Maybe String -> Html Msg
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
                , onClick <| SlideMsg model <| Slide.Messages.Color color
                ]
                []
            ]
