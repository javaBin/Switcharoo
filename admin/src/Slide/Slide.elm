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


icon : String -> Html msg
icon c =
    i [ class <| "icon-" ++ c ] []


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
    li [ classList [ ( "slide--drop", True ), ( "slide--drop--moving", moving ) ], attribute "ondragover" "return false", onDrop <| Drop location ] []


deleteButton : SlideModel -> Html Msg
deleteButton model =
    button [ class "slide__delete", onClickStopPropagation <| ToggleDelete model ] [ Icons.deleteIcon ]


editButton : SlideModel -> Html Msg
editButton model =
    button [ class "slide__edit", onClickStopPropagation <| Edit model ] [ Icons.editIcon ]


slideIndex : SlideModel -> Html Msg
slideIndex model =
    div [ class "slide__index" ] [ text <| toString model.slide.index ]


viewText : SlideModel -> ( String, String ) -> Html Msg
viewText model opacity =
    let
        borderStyle =
            Maybe.withDefault "transparent" model.slide.color
    in
        li
            [ class "slide"
            , onClick <| ToggleVisibility model
            , style [ ( "borderColor", borderStyle ), opacity ]
            , attribute "draggable" "true"
            , onDragStart <| Move model
            , onDragEnd CancelMove
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


viewImage : SlideModel -> ( String, String ) -> Html Msg
viewImage model opacity =
    let
        borderStyle =
            Maybe.withDefault "transparent" model.slide.color
    in
        li
            [ class "slide slide--image"
            , onClick <| ToggleVisibility model
            , style [ ( "borderColor", borderStyle ), opacity ]
            , attribute "draggable" "true"
            , onDragStart <| Move model
            , onDragEnd CancelMove
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


viewVideo : SlideModel -> ( String, String ) -> Html Msg
viewVideo model opacity =
    let
        borderStyle =
            Maybe.withDefault "transparent" model.slide.color
    in
        li
            [ class "slide slide--video"
            , onClick <| ToggleVisibility model
            , style [ ( "borderColor", borderStyle ), opacity ]
            , attribute "draggable" "true"
            , onDragStart <| Move model
            , onDragEnd CancelMove
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


editView : SlideModel -> Html Msg
editView model =
    if model.slide.type_ == "text" then
        editTextView model
    else
        editMediaView model


editMediaView : SlideModel -> Html Msg
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


editTextView : SlideModel -> Html Msg
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


selectColorView : SlideModel -> Html Msg
selectColorView model =
    div []
        [ ul [ class "modal__color" ] <|
            List.map (singleColorView model) [ Nothing, Just "#0078c9", Just "#ef8717", Just "#58836a", Just "#874b85" ]
        ]


singleColorView : SlideModel -> Maybe String -> Html Msg
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


confirmDeleteView : SlideModel -> Html Msg
confirmDeleteView model =
    div [ classList [ ( "slide__confirm-delete", True ), ( "slide__confirm-delete--visible", model.deleteMode ) ] ]
        [ button [ class "button button--cancel", onClickStopPropagation <| ToggleDelete model ] [ text "Cancel" ]
        , button [ class "button slide__delete-button", onClickStopPropagation <| Delete model ] [ text "Delete" ]
        ]


onDragStart : msg -> Attribute msg
onDragStart msg =
    on "dragstart" <| Json.Decode.succeed msg


onDragEnd : msg -> Attribute msg
onDragEnd msg =
    on "dragend" <| Json.Decode.succeed msg


onDrop : msg -> Attribute msg
onDrop msg =
    onPreventHelper "drop" msg


onPreventHelper : String -> msg -> Attribute msg
onPreventHelper event msg =
    onWithOptions
        event
        { preventDefault = True
        , stopPropagation = False
        }
        (Json.Decode.succeed msg)
