module Slide.Slide exposing (..)

import Models.Slides exposing (..)
import Slides.Messages exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, classList, style, type_, id, value, draggable, placeholder, disabled, attribute, src)
import Html.Events exposing (onClick, onInput, on)
import Json.Decode exposing (succeed)
import Http
import Events exposing (onClickStopPropagation)
import Ports exposing (FileData, fileSelected, fileUploadSucceeded, fileUploadFailed)
import Backend exposing (editSlide, createSlide, deleteSlide)
import Models.Conference exposing (Conference)


init : ( Models.Slides.SlideModel, Cmd Msg )
init =
    ( Models.Slides.initSlideModel, Cmd.none )


createOrEditSlide : Conference -> Slide -> (Result.Result Http.Error Slide -> msg) -> Cmd msg
createOrEditSlide conference model msg =
    if model.id == -1 then
        createSlide conference model msg
    else
        editSlide conference model msg


subscriptions : Models.Slides.SlideModel -> Sub Msg
subscriptions model =
    Sub.batch [ fileUploadSucceeded <| FileUploaded model, fileUploadFailed <| FileUploadFailed model ]


icon : String -> Html msg
icon c =
    i [ class <| "icon-" ++ c ] []


view : Models.Slides.SlideModel -> Html Msg
view model =
    case model.slide.type_ of
        "text" ->
            viewText model

        "image" ->
            viewImage model

        _ ->
            viewVideo model


deleteButton : Models.Slides.SlideModel -> Html Msg
deleteButton model =
    button [ class "slide__delete", onClickStopPropagation <| ToggleDelete model ] [ icon "trash" ]


editButton : Models.Slides.SlideModel -> Html Msg
editButton model =
    button [ class "slide__edit", onClickStopPropagation <| Edit model ] [ icon "pencil" ]


slideIndex : Models.Slides.SlideModel -> Html Msg
slideIndex model =
    div [ class "slide__index" ] [ text <| toString model.slide.index ]


viewText : Models.Slides.SlideModel -> Html Msg
viewText model =
    let
        borderStyle =
            Maybe.withDefault "transparent" model.slide.color
    in
        li
            [ class "slide"
            , onClick <| ToggleVisibility model
            , style [ ( "borderColor", borderStyle ) ]
            ]
            [ div
                [ classList
                    [ ( "slide__content slide__content--text", True )
                    , ( "slide__content--visible", model.slide.visible )
                    ]
                ]
                [ div [ class "slide__title" ] [ text model.slide.title ]
                , div [ class "slide__body" ] [ text model.slide.body ]
                ]
            , deleteButton model
            , editButton model
            , slideIndex model
            , confirmDeleteView model
            ]


viewImage : Models.Slides.SlideModel -> Html Msg
viewImage model =
    let
        borderStyle =
            Maybe.withDefault "transparent" model.slide.color
    in
        li
            [ class "slide slide--image"
            , onClick <| ToggleVisibility model
            , style [ ( "borderColor", borderStyle ) ]
            ]
            [ div
                [ classList
                    [ ( "slide__content slide__content--image", True )
                    , ( "slide__content--visible", model.slide.visible )
                    ]
                , style
                    [ ( "background-image", "url(" ++ model.slide.body ++ ")" ) ]
                ]
                []
            , deleteButton model
            , editButton model
            , slideIndex model
            , confirmDeleteView model
            ]


viewVideo : Models.Slides.SlideModel -> Html Msg
viewVideo model =
    let
        borderStyle =
            Maybe.withDefault "transparent" model.slide.color
    in
        li
            [ class "slide slide--video"
            , onClick <| ToggleVisibility model
            , style [ ( "borderColor", borderStyle ) ]
            ]
            [ div
                [ classList
                    [ ( "slide__content slide__content--video", True )
                    , ( "slide__content--visible", model.slide.visible )
                    ]
                ]
                [ div [ class "slide__title" ] [ text model.slide.name ]
                , div [ class "slide__body" ] [ text "(video)" ]
                ]
            , deleteButton model
            , editButton model
            , slideIndex model
            , confirmDeleteView model
            ]


editView : Models.Slides.SlideModel -> Html Msg
editView model =
    if model.slide.type_ == "text" then
        editTextView model
    else
        editMediaView model


editMediaView : Models.Slides.SlideModel -> Html Msg
editMediaView model =
    div []
        [ div [ class "tabs" ]
            [ button
                [ class "tabs__tab tabs__tab--active"
                , disabled True
                ]
                [ text "Media" ]
            , button
                [ class "tabs__tab"
                , onClickStopPropagation <| TextSlide model
                ]
                [ text "Text" ]
            ]
        , div [ class "modal__slide" ]
            [ input
                [ type_ "text"
                , class "input modal__index"
                , onInput <| Name model
                , value model.slide.name
                , placeholder "Name"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__index"
                , onInput <| Index model
                , value <| toString model.slide.index
                , placeholder "Index"
                ]
                []
            , input
                [ type_ "file"
                , id "MediaInputId"
                , on "change" (succeed <| FileSelected model)
                ]
                []
            , selectColorView model
            ]
        ]


editTextView : Models.Slides.SlideModel -> Html Msg
editTextView model =
    div []
        [ div [ class "tabs" ]
            [ button
                [ class "tabs__tab"
                , onClickStopPropagation <| MediaSlide model
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
                , onInput <| Name model
                , value model.slide.name
                , placeholder "Name"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__index"
                , onInput <| Index model
                , value <| toString model.slide.index
                , placeholder "Index"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__title"
                , onInput <| Title model
                , value model.slide.title
                , placeholder "Title"
                ]
                []
            , textarea
                [ onInput <| Body model
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
                , onClick <| Color model color
                ]
                []
            ]


confirmDeleteView : Models.Slides.SlideModel -> Html Msg
confirmDeleteView model =
    div [ classList [ ( "slide__confirm-delete", True ), ( "slide__confirm-delete--visible", model.deleteMode ) ] ]
        [ button [ class "button button--cancel", onClickStopPropagation <| ToggleDelete model ] [ text "Cancel" ]
        , button [ class "button slide__delete-button", onClickStopPropagation <| Delete model ] [ text "Delete" ]
        ]
