module Modal exposing (Model, Msg, init, update, subscriptions, view)

import Html exposing (Html, div, button, text, i, input)
import Html.Attributes exposing (class, classList, attribute, type', id)
import Html.Events exposing (onClick, on)
import Events exposing (onClickStopPropagation)
import Ports exposing (FileData, fileSelected, fileUploadSucceeded, fileUploadFailed)
import Json.Decode exposing (succeed)
-- import Http exposing (Request, Response, Body, defaultSettings, send)
-- import HttpBuilder exposing (..)
import Debug exposing (log)
-- import Task
import Slide
import Task
import Http exposing (Response)

type alias Model =
    { show : Bool
    , id : String
    , slide : Maybe Slide.Model
    }

init : (Model, Cmd Msg)
init = (Model False "MediaInputId" Nothing, Cmd.none)

type Msg
    = Show
    | Hide
    | FileSelected
    | FileUploaded FileData
    | FileUploadFailed String
    | CreateSlide
    | CreateFailed Http.RawError
    | CreateSucceeded Response

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    log (toString msg) <|
    case msg of
        Show ->
            ({model | show = True}, Cmd.none)

        Hide ->
            init

        FileSelected ->
            (model, fileSelected model.id)

        FileUploaded fileData ->
            ({model | slide = Just (Slide.Model "" fileData.location fileData.location True "0" fileData.filetype)}, Cmd.none)

        FileUploadFailed error ->
            log (toString error) ({model | slide = Nothing}, Cmd.none)

        CreateSlide ->
            case model.slide of
                Nothing -> (model, Cmd.none)
                Just slide -> (model, createSlide slide)

        CreateFailed _ ->
            (model, Cmd.none)

        CreateSucceeded _ ->
            update Hide model

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch [fileUploadSucceeded FileUploaded, fileUploadFailed FileUploadFailed]

createSlide : Slide.Model -> Cmd Msg
createSlide model = Task.perform CreateFailed CreateSucceeded <| Slide.createSlide model

icon : String -> Html msg
icon c =
    i [ class <| "icon-" ++ c ] []

view : Model -> Html Msg
view model =
    div [ class "slide slide--new-slide", onClick Show ]
        [ div [ classList [ ("modal", True), ("modal--visible", model.show) ] ]
              [ showModalBackdrop model ]
        ]

showModalBackdrop : Model -> Html Msg
showModalBackdrop model =
    div [ classList [ ("modal", True), ("modal--visible", model.show) ] ]
        [ div [ class "modal__backdrop", onClickStopPropagation Hide ]
              [ showModal model ]
        ]

showModal : Model -> Html Msg
showModal model =
    div [ class "modal__wrapper", onClickStopPropagation Show ]
        [ div [ class "modal__header" ]
              [ text "New Slide" ]
        , showModalContent model
        , showModalFooter model
        ]

showModalContent : Model -> Html Msg
showModalContent model =
    div [ class "modal__content" ]
        [ input [type' "file", id model.id, on "change" (succeed FileSelected) ]
                []
        ]

showModalFooter : Model -> Html Msg
showModalFooter model =
    div [ class "modal__footer" ]
        [ button [ class "button button--cancel", onClickStopPropagation Hide ]
                 [ icon "close" ]
        , button [ class "button button--ok modal__save", onClickStopPropagation CreateSlide ]
                 [ icon "check" ]
        ]
