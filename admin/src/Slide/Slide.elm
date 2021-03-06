module Slide.Slide exposing (..)

import Models.Slides exposing (..)
import Slides.Messages exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, classList, style, type_, id, value, draggable, placeholder, disabled, attribute, src)
import Html.Events exposing (onClick, onInput, on, onWithOptions)
import Json.Decode exposing (succeed)
import Http
import Events exposing (onClickStopPropagation)
import Ports exposing (FileData, fileSelected, fileUploadSucceeded, fileUploadFailed)
import Backend exposing (editSlide, createSlide, deleteSlide)
import Models.Conference exposing (Conference)
import Icons
import Events


init : ( SlideModel, Cmd Msg )
init =
    ( Models.Slides.initSlideModel, Cmd.none )


createOrEditSlide : Conference -> Slide -> (Result.Result Http.Error Slide -> msg) -> Cmd msg
createOrEditSlide conference model msg =
    if model.id == -1 then
        createSlide conference model msg
    else
        editSlide conference model msg


subscriptions : SlideModel -> Sub Msg
subscriptions model =
    Sub.batch [ fileUploadSucceeded <| FileUploaded model, fileUploadFailed <| FileUploadFailed model ]


view : SlideModel -> Bool -> Html Msg
view model moving =
    let
        opacity =
            if moving then
                ( "opacity", "0.1" )
            else
                ( "opacity", "1" )
    in
        case model.slide.type_ of
            "text" ->
                viewText model opacity

            "image" ->
                viewImage model opacity

            _ ->
                viewVideo model opacity


viewDrop : Bool -> Int -> Html Msg
viewDrop moving location =
    li [ classList [ ( "slide--drop", True ), ( "slide--drop--moving", moving ) ], attribute "ondragover" "return false", Events.onDrop <| Drop location ] []


deleteButton : SlideModel -> Html Msg
deleteButton model =
    button [ class "slide__delete", onClickStopPropagation <| ToggleDelete model ] [ Icons.deleteIcon ]


editButton : SlideModel -> Html Msg
editButton model =
    button [ class "slide__edit", onClickStopPropagation <| Edit model ] [ Icons.editIcon ]


slideIndex : SlideModel -> Html Msg
slideIndex model =
    div [ class "slide__index" ] [ text <| toString model.slide.index ]


colorIndicator : SlideModel -> Html msg
colorIndicator model =
    let
        color =
            Maybe.withDefault "transparent" model.slide.color
    in
        div [ class "slide__color-indicator", style [ ( "background-color", color ) ] ] []


viewText : SlideModel -> ( String, String ) -> Html Msg
viewText model opacity =
    li
        [ class "slide"
        , onClick <| ToggleVisibility model
        , style [ opacity ]
        , attribute "draggable" "true"
        , Events.onDragStart <| Move model
        , Events.onDragEnd CancelMove
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
        , colorIndicator model
        ]


viewImage : SlideModel -> ( String, String ) -> Html Msg
viewImage model opacity =
    li
        [ class "slide slide--image"
        , onClick <| ToggleVisibility model
        , style [ opacity ]
        , attribute "draggable" "true"
        , Events.onDragStart <| Move model
        , Events.onDragEnd CancelMove
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
        , colorIndicator model
        ]


viewVideo : SlideModel -> ( String, String ) -> Html Msg
viewVideo model opacity =
    li
        [ class "slide slide--video"
        , onClick <| ToggleVisibility model
        , style [ opacity ]
        , attribute "draggable" "true"
        , Events.onDragStart <| Move model
        , Events.onDragEnd CancelMove
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
        , colorIndicator model
        ]


confirmDeleteView : SlideModel -> Html Msg
confirmDeleteView model =
    div [ classList [ ( "slide__confirm-delete", True ), ( "slide__confirm-delete--visible", model.deleteMode ) ] ]
        [ button [ class "button button--cancel", onClickStopPropagation <| ToggleDelete model ] [ text "Cancel" ]
        , button [ class "button slide__delete-button", onClickStopPropagation <| Delete model ] [ text "Delete" ]
        ]
