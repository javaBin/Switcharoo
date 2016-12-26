module Slides.Slides exposing (..)

import Slides.Messages exposing (..)
import Slides.Model exposing (..)
import Html exposing (Html, text, ul, map)
import Json.Decode exposing (Decoder, list)
import Slide.Slide
import Slide.Model
import Slide.Messages
import Modal.Modal
import Modal.Messages
import Backend


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetSlides ->
            ( model, Backend.getSlides decoder )

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
                    Slide.Messages.DeleteResponse (Ok _) ->
                        ( { model | slides = newModels }
                        , Cmd.batch <|
                            [ Backend.getSlides decoder ]
                                ++ newCmds
                        )

                    Slide.Messages.EditResponse (Ok _) ->
                        editSlide model newModels slide

                    _ ->
                        ( { model | slides = newModels }, Cmd.batch newCmds )

        NewSlideModal msg ->
            let
                ( newModal, newModalCmd ) =
                    Modal.Modal.update msg model.modal
            in
                case msg of
                    Modal.Messages.CreateResponse (Ok _) ->
                        ( { model | modal = newModal }
                        , Cmd.batch [ Cmd.map NewSlideModal newModalCmd, Backend.getSlides decoder ]
                        )

                    _ ->
                        ( { model | modal = newModal }
                        , Cmd.map NewSlideModal newModalCmd
                        )


updateSlide : Slide.Model.Model -> Slide.Messages.Msg -> Slide.Model.Model -> ( Slide.Model.Model, Cmd Msg )
updateSlide newModel msg currentModel =
    if newModel.id == currentModel.id then
        let
            ( newSlide, newCmd ) =
                Slide.Slide.update msg newModel
        in
            ( newSlide, Cmd.map (Slide newSlide) newCmd )
    else
        ( currentModel, Cmd.none )


editSlide : Model -> List Slide.Model.Model -> Slide.Model.Model -> ( Model, Cmd Msg )
editSlide model newSlides slide =
    let
        ( newModal, newModalCmd ) =
            Modal.Modal.update (Modal.Messages.Edit slide) model.modal
    in
        ( { model | slides = newSlides, modal = newModal }, Cmd.map NewSlideModal newModalCmd )


decoder : Decoder (List Slide.Model.Model)
decoder =
    list Backend.slideDecoder


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map NewSlideModal <| Modal.Modal.subscriptions model.modal


view : Model -> List (Html Msg)
view model =
    let
        newSlide =
            Html.map NewSlideModal <| Modal.Modal.view model.modal
    in
        newSlide :: List.map (\slide -> map (Slide slide) (Slide.Slide.view slide)) model.slides
