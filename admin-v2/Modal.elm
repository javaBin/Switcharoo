module Modal exposing (Model, Msg, init, update, subscriptions, view)

import Html exposing (Html, div, button, text, i, input)
import Html.App as App
import Html.Attributes exposing (class, classList, attribute, type', id, disabled)
import Html.Events exposing (onClick, on, onInput)
import Events exposing (onClickStopPropagation)
import Debug exposing (log)
import Slide
import Task
import Http exposing (Response)

type alias Model =
    { show : Bool
    , id : String
    , slide : Slide.Model
    }

init : (Model, Cmd Msg)
init = (Model False "MediaInputId" Slide.initModel, Cmd.none)

type Msg
    = Show
    | Hide
    | CreateSlide
    | CreateFailed Http.RawError
    | CreateSucceeded Response
    | CurrentSlide Slide.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    log (toString msg) <|
    case msg of
        Show ->
            ({model | show = True}, Cmd.none)

        Hide ->
            init

        CreateSlide ->
            (model, createSlide model.slide)

        CreateFailed _ ->
            (model, Cmd.none)

        CreateSucceeded _ ->
            update Hide model

        CurrentSlide msg ->
            let
                (newSlide, newCmd) = Slide.update msg model.slide
            in
                ({model | slide = newSlide}, Cmd.map CurrentSlide newCmd)

subscriptions : Model -> Sub Msg
subscriptions model = Sub.map CurrentSlide <| Slide.subscriptions model.slide

createSlide : Slide.Model -> Cmd Msg
createSlide model = Task.perform CreateFailed CreateSucceeded <| Slide.createSlide model

icon : String -> Html msg
icon c =
    i [ class <| "icon-" ++ c ] []

isEmpty : Slide.Model -> Bool
isEmpty m =
    if m.body == "" then
        True
    else
        False

view : Model -> Html Msg
view model =
    div [ class "slide slide--new-slide", onClick Show ]
        [ div [ class "slide__content slide__content--new-slide" ] []
        , div [ classList [ ("modal", True), ("modal--visible", model.show) ] ]
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

-- showImageModalContent : Model -> Html Msg
-- showImageModalContent model =
--     div [ class "modal__content" ]
--         [ input [type' "file", id model.id, on "change" (succeed FileSelected) ]
--                 []
--         ]

showModalContent : Model -> Html Msg
showModalContent model =
    div [ class "modal__content" ]
        [ App.map CurrentSlide (Slide.editView model.slide)
        ]

showModalFooter : Model -> Html Msg
showModalFooter model =
    div [ class "modal__footer" ]
        [ button [ class "button button--cancel", onClickStopPropagation Hide ]
                 [ icon "close" ]
        , button [ class "button button--ok modal__save"
                 , onClickStopPropagation CreateSlide
                 , disabled <| isEmpty model.slide ]
                 [ icon "check" ]
        ]
