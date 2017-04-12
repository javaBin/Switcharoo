module Slide.Slide exposing (..)

import Slide.Model exposing (..)
import Slide.Messages exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, classList, style, type_, id, value, draggable, placeholder, disabled, attribute, src)
import Html.Events exposing (onClick, onInput, on)
import Json.Decode exposing (Decoder, succeed, string, bool, field, int)
import Http
import Events exposing (onClickStopPropagation)
import Ports exposing (FileData, fileSelected, fileUploadSucceeded, fileUploadFailed)
import Backend exposing (editSlide, createSlide, deleteSlide)


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleVisibility ->
            let
                slideModel =
                    model.slide

                newSlide =
                    { slideModel | visible = not slideModel.visible }
            in
                ( { model | slide = newSlide }, editSlide newSlide ToggleResponse )

        ToggleResponse _ ->
            ( model, Cmd.none )

        Edit ->
            ( model, editSlide model.slide EditResponse )

        EditResponse _ ->
            ( model, Cmd.none )

        CreateResponse _ ->
            ( model, Cmd.none )

        ToggleDelete ->
            ( { model | deleteMode = not model.deleteMode }, Cmd.none )

        Delete ->
            ( model, deleteSlide model.slide )

        DeleteResponse _ ->
            ( model, Cmd.none )

        Name newName ->
            ( updateSlide model <| \s -> { s | name = newName }, Cmd.none )

        Title newTitle ->
            ( updateSlide model <| \s -> { s | title = newTitle }, Cmd.none )

        Body newBody ->
            ( updateSlide model <| \s -> { s | body = newBody }, Cmd.none )

        Index newIndex ->
            case String.toInt newIndex of
                Ok n ->
                    ( updateSlide model <| \s -> { s | index = n }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        TextSlide ->
            ( updateSlide model <| \s -> { s | type_ = "text" }, Cmd.none )

        MediaSlide ->
            ( updateSlide model <| \s -> { s | type_ = "media" }, Cmd.none )

        FileSelected ->
            ( model, fileSelected "MediaInputId" )

        FileUploaded f ->
            let
                _ =
                    Debug.log (toString f) "yes"
            in
                ( updateSlide model <| \s -> { s | title = f.location, body = f.location, type_ = f.filetype }
                , Cmd.none
                )

        FileUploadFailed error ->
            let
                _ =
                    Debug.log (toString error) "no"
            in
                ( initModel, Cmd.none )


updateSlide : Model -> (Slide -> Slide) -> Model
updateSlide model fn =
    { model | slide = (fn model.slide) }


createOrEditSlide : Slide -> (Result.Result Http.Error Slide -> msg) -> Cmd msg
createOrEditSlide model msg =
    if model.id == -1 then
        createSlide model msg
    else
        editSlide model msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ fileUploadSucceeded FileUploaded, fileUploadFailed FileUploadFailed ]


icon : String -> Html msg
icon c =
    i [ class <| "icon-" ++ c ] []


view : Model -> Html Msg
view model =
    case model.slide.type_ of
        "text" ->
            viewText model

        "image" ->
            viewImage model

        _ ->
            viewVideo model


deleteButton : Slide -> Html Msg
deleteButton model =
    button [ class "slide__delete", onClickStopPropagation ToggleDelete ] [ icon "trash" ]


editButton : Slide -> Html Msg
editButton model =
    button [ class "slide__edit", onClickStopPropagation Edit ] [ icon "pencil" ]


slideIndex : Slide -> Html Msg
slideIndex model =
    div [ class "slide__index" ] [ text <| toString model.index ]


viewText : Model -> Html Msg
viewText model =
    li
        [ class "slide"
        , onClick ToggleVisibility
        ]
        [ div
            [ classList
                [ ( "slide__content", True )
                , ( "slide__content--text", True )
                , ( "slide__content--visible", model.slide.visible )
                ]
            ]
            [ div [ class "slide__title" ] [ text model.slide.title ]
            , div [ class "slide__body" ] [ text model.slide.body ]
            ]
        , deleteButton model.slide
        , editButton model.slide
        , slideIndex model.slide
        , confirmDeleteView model
        ]


viewImage : Model -> Html Msg
viewImage model =
    li
        [ class "slide slide--image"
        , onClick ToggleVisibility
        ]
        [ div
            [ classList
                [ ( "slide__content slide__content--image", True )
                , ( "slide__content--visible", model.slide.visible )
                ]
            , style [ ( "background-image", "url(" ++ model.slide.body ++ ")" ) ]
            ]
            []
        , deleteButton model.slide
        , editButton model.slide
        , slideIndex model.slide
        ]


viewVideo : Model -> Html Msg
viewVideo model =
    li
        [ class "slide slide--video"
        , onClick ToggleVisibility
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
        , deleteButton model.slide
        , editButton model.slide
        , slideIndex model.slide
        ]


editView : Model -> Html Msg
editView model =
    if model.slide.type_ == "text" then
        editTextView model
    else
        editMediaView model


editMediaView : Model -> Html Msg
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
                , onClickStopPropagation TextSlide
                ]
                [ text "Text" ]
            ]
        , div [ class "modal__slide" ]
            [ input
                [ type_ "text"
                , class "input modal__index"
                , onInput Name
                , value model.slide.name
                , placeholder "Name"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__index"
                , onInput Index
                , value <| toString model.slide.index
                , placeholder "Index"
                ]
                []
            , input
                [ type_ "file"
                , id "MediaInputId"
                , on "change" (succeed FileSelected)
                ]
                []
            ]
        ]


editTextView : Model -> Html Msg
editTextView model =
    div []
        [ div [ class "tabs" ]
            [ button
                [ class "tabs__tab"
                , onClickStopPropagation MediaSlide
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
                , onInput Name
                , value model.slide.name
                , placeholder "Name"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__index"
                , onInput Index
                , value <| toString model.slide.index
                , placeholder "Index"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__title"
                , onInput Title
                , value model.slide.title
                , placeholder "Title"
                ]
                []
            , textarea
                [ onInput Body
                , class "input modal__body"
                , value model.slide.body
                , placeholder "Body"
                ]
                []
            ]
        ]


confirmDeleteView : Model -> Html Msg
confirmDeleteView model =
    div [ classList [ ( "slide__confirm-delete", True ), ( "slide__confirm-delete--visible", model.deleteMode ) ] ]
        [ button [ class "button button--cancel", onClickStopPropagation ToggleDelete ] [ text "Cancel" ]
        , button [ class "button slide__delete-button", onClickStopPropagation Delete ] [ text "Delete" ]
        ]
