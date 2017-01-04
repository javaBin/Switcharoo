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
                newModel =
                    { model | visible = not model.visible }

                _ =
                    Debug.log "model" newModel
            in
                ( newModel, editSlide newModel ToggleResponse )

        ToggleResponse _ ->
            ( model, Cmd.none )

        Edit ->
            ( model, editSlide model EditResponse )

        EditResponse _ ->
            ( model, Cmd.none )

        CreateResponse _ ->
            ( model, Cmd.none )

        Delete ->
            ( model, deleteSlide model )

        DeleteResponse _ ->
            ( model, Cmd.none )

        Name newName ->
            ( { model | name = newName }, Cmd.none )

        Title newTitle ->
            ( { model | title = newTitle }, Cmd.none )

        Body newBody ->
            ( { model | body = newBody }, Cmd.none )

        Index newIndex ->
            case String.toInt newIndex of
                Ok n ->
                    ( { model | index = n }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        TextSlide ->
            ( { model | type_ = "text" }, Cmd.none )

        MediaSlide ->
            ( { model | type_ = "media" }, Cmd.none )

        FileSelected ->
            ( model, fileSelected "MediaInputId" )

        FileUploaded fileData ->
            ( { model | title = fileData.location, body = fileData.location, type_ = fileData.filetype }, Cmd.none )

        FileUploadFailed error ->
            ( initModel, Cmd.none )


createOrEditSlide : Model -> (Result.Result Http.Error Model -> msg) -> Cmd msg
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
    case model.type_ of
        "text" ->
            viewText model

        "image" ->
            viewImage model

        _ ->
            viewVideo model


deleteButton : Model -> Html Msg
deleteButton model =
    button [ class "slide__delete", onClickStopPropagation Delete ] [ icon "trash" ]


editButton : Model -> Html Msg
editButton model =
    button [ class "slide__edit", onClickStopPropagation Edit ] [ icon "pencil" ]


slideIndex : Model -> Html Msg
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
                , ( "slide__content--visible", model.visible )
                ]
            ]
            [ div [ class "slide__title" ] [ text model.title ]
            , div [ class "slide__body" ] [ text model.body ]
            ]
        , deleteButton model
        , editButton model
        , slideIndex model
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
                , ( "slide__content--visible", model.visible )
                ]
            , style [ ( "background-image", "url(" ++ model.body ++ ")" ) ]
            ]
            []
        , deleteButton model
        , editButton model
        , slideIndex model
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
                , ( "slide__content--visible", model.visible )
                ]
            ]
            [ div [ class "slide__title" ] [ text model.name ]
            , div [ class "slide__body" ] [ text "(video)" ]
            ]
        , deleteButton model
        , editButton model
        , slideIndex model
        ]


editView : Model -> Html Msg
editView model =
    if model.type_ == "text" then
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
                , value model.name
                , placeholder "Name"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__index"
                , onInput Index
                , value <| toString model.index
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
                , value model.name
                , placeholder "Name"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__index"
                , onInput Index
                , value <| toString model.index
                , placeholder "Index"
                ]
                []
            , input
                [ type_ "text"
                , class "input modal__title"
                , onInput Title
                , value model.title
                , placeholder "Title"
                ]
                []
            , textarea
                [ onInput Body
                , class "input modal__body"
                , value model.body
                , placeholder "Body"
                ]
                []
            ]
        ]
