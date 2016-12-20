module Slides exposing (..)

import Html exposing (Html, text, ul, map)
import Json.Decode exposing (Decoder, list)
import Http
import Task
import Slide
import Modal


type alias Model =
    { slides : List Slide.Model
    , modal : Modal.Model
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] Modal.init, getSlides )


type Msg
    = GetSlides
    | SlidesResponse (Result Http.Error (List Slide.Model))
    | Slide Slide.Model Slide.Msg
    | NewSlideModal Modal.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetSlides ->
            ( model, getSlides )

        SlidesResponse (Ok newSlides) ->
            ( { model | slides = newSlides }, Cmd.none )

        SlidesResponse (Err _) ->
            ( model, Cmd.none )

        Slide slide msg ->
            let
                ( newModels, newCmds ) =
                    List.unzip (List.map (updateSlide slide msg) model.slides)
            in
                case msg of
                    Slide.DeleteResponse (Ok _) ->
                        ( { model | slides = newModels }, Cmd.batch <| [ getSlides ] ++ newCmds )

                    Slide.EditResponse (Ok _) ->
                        editSlide model newModels slide

                    _ ->
                        ( { model | slides = newModels }, Cmd.batch newCmds )

        NewSlideModal msg ->
            let
                ( newModal, newModalCmd ) =
                    Modal.update msg model.modal
            in
                case msg of
                    Modal.CreateResponse (Ok _) ->
                        ( { model | modal = newModal }
                        , Cmd.batch [ Cmd.map NewSlideModal newModalCmd, getSlides ]
                        )

                    _ ->
                        ( { model | modal = newModal }
                        , Cmd.map NewSlideModal newModalCmd
                        )


updateSlide : Slide.Model -> Slide.Msg -> Slide.Model -> ( Slide.Model, Cmd Msg )
updateSlide newModel msg currentModel =
    if newModel.id == currentModel.id then
        let
            ( newSlide, newCmd ) =
                Slide.update msg newModel
        in
            ( newSlide, Cmd.map (Slide newSlide) newCmd )
    else
        ( currentModel, Cmd.none )


editSlide : Model -> List Slide.Model -> Slide.Model -> ( Model, Cmd Msg )
editSlide model newSlides slide =
    let
        ( newModal, newModalCmd ) =
            Modal.update (Modal.Edit slide) model.modal
    in
        ( { model | slides = newSlides, modal = newModal }, Cmd.map NewSlideModal newModalCmd )


decoder : Decoder (List Slide.Model)
decoder =
    list Slide.decoder


getSlides : Cmd Msg
getSlides =
    Http.send SlidesResponse <|
        Http.get "/slides" decoder


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map NewSlideModal <| Modal.subscriptions model.modal


view : Model -> List (Html Msg)
view model =
    let
        newSlide =
            Html.map NewSlideModal <| Modal.view model.modal
    in
        newSlide :: List.map (\slide -> map (Slide slide) (Slide.view slide)) model.slides
