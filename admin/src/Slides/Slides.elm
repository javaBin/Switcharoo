module Slides.Slides exposing (..)

import Slides.Messages exposing (..)
import Models.Slides
import Html exposing (Html, text, ul, map, div, li)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder, list)
import Slide.Slide
import Slide.Model
import Slide.Messages
import Backend
import Decoders.Slide
import Models.Slides
import Models.Conference exposing (Conference)
import Popup


update : Conference -> Msg -> Models.Slides.Slides -> ( Models.Slides.Slides, Cmd Msg )
update conference msg model =
    case msg of
        GetSlides ->
            ( model, Backend.getSlides conference )

        SlidesResponse (Ok newSlides) ->
            let
                slides =
                    List.map (\slide -> Models.Slides.SlideModel slide False) newSlides
            in
                ( { model | slides = slides }, Cmd.none )

        SlidesResponse (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        Slide slide msg ->
            let
                ( newModels, newCmds ) =
                    List.unzip (List.map (updateSlide conference slide msg) model.slides)
            in
                case msg of
                    Slide.Messages.DeleteResponse (Ok _) ->
                        ( { model | slides = newModels }
                        , Cmd.batch <|
                            [ Backend.getSlides conference ]
                                ++ newCmds
                        )

                    Slide.Messages.EditResponse (Ok _) ->
                        ( { model | newSlide = Just (Popup.state slide "Edit slide") }, Cmd.none )

                    _ ->
                        ( { model | slides = newModels }, Cmd.batch newCmds )

        NewSlide ->
            ( { model | newSlide = Just (Popup.state Models.Slides.initSlideModel "New slide") }, Cmd.none )


updateSlide : Conference -> Models.Slides.SlideModel -> Slide.Messages.Msg -> Slide.Model.Model -> ( Models.Slides.SlideModel, Cmd Msg )
updateSlide conference newModel msg currentModel =
    if newModel.slide.id == currentModel.slide.id then
        let
            ( newSlide, newCmd ) =
                Slide.Slide.update conference msg newModel
        in
            ( newSlide, Cmd.map (Slide newSlide) newCmd )
    else
        ( currentModel, Cmd.none )


view : Models.Slides.Slides -> List (Html Msg)
view model =
    viewNewSlide :: List.map (\slide -> map (Slide slide) (Slide.Slide.view slide)) model.slides


viewNewSlide : Html Msg
viewNewSlide =
    li [ class "slide slide--new-slide", onClick NewSlide ]
        [ div [ class "slide__content slide__content--new-slide" ] []
        ]
