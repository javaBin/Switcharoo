module Slides.Slides exposing (..)

import Slides.Messages exposing (..)
import Models.Slides exposing (Slides, SlideModel, Slide, initSlideModel)
import Html exposing (Html, text, ul, map, div, li)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder, list)
import Slide.Slide
import Slide.Model
import Slides.Messages
import Decoders.Slide
import Models.Slides
import Models.Conference exposing (Conference)
import Popup
import Ports exposing (fileSelected)
import Backend exposing (editSlide, createSlide, deleteSlide)


update : Conference -> Msg -> Slides -> ( Slides, Cmd Msg )
update conference msg model =
    case msg of
        GetSlides ->
            ( model, Backend.getSlides conference )

        SlidesResponse (Ok newSlides) ->
            let
                slides =
                    List.map (\slide -> SlideModel slide False) newSlides
            in
                ( { model | slides = slides }, Cmd.none )

        SlidesResponse (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        NewSlide ->
            ( { model | newSlide = Just (Popup.state initSlideModel "New slide") }, Cmd.none )

        ToggleVisibility slide ->
            let
                slideModel =
                    slide.slide

                newSlide =
                    { slideModel | visible = not slideModel.visible }
            in
                ( setSlide model { slide | slide = newSlide }, editSlide conference newSlide ToggleResponse )

        ToggleResponse _ ->
            ( model, Cmd.none )

        Edit slide ->
            ( { model | newSlide = Just <| Popup.state slide "Edit slide" }, Cmd.none )

        CreateResponse _ ->
            ( model, Cmd.none )

        ToggleDelete slide ->
            ( setSlide model { slide | deleteMode = not slide.deleteMode }, Cmd.none )

        Delete slide ->
            ( model, deleteSlide conference slide.slide )

        DeleteResponse _ ->
            ( model, Backend.getSlides conference )

        Name slide newName ->
            ( setEditSlide model <| updateSlide slide <| \s -> { s | name = newName }, Cmd.none )

        Title slide newTitle ->
            ( setEditSlide model <| updateSlide slide <| \s -> { s | title = newTitle }, Cmd.none )

        Body slide newBody ->
            ( setEditSlide model <| updateSlide slide <| \s -> { s | body = newBody }, Cmd.none )

        Index slide newIndex ->
            case String.toInt newIndex of
                Ok n ->
                    ( setEditSlide model <| updateSlide slide <| \s -> { s | index = n }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        TextSlide slide ->
            ( setEditSlide model <| updateSlide slide <| \s -> { s | type_ = "text" }, Cmd.none )

        MediaSlide slide ->
            ( setEditSlide model <| updateSlide slide <| \s -> { s | type_ = "media" }, Cmd.none )

        Color slide color ->
            ( setEditSlide model <| updateSlide slide <| \s -> { s | color = color }, Cmd.none )

        FileSelected slide ->
            ( model, fileSelected "MediaInputId" )

        FileUploaded slide f ->
            Debug.log (toString f)
                ( setEditSlide model <| updateSlide slide <| \s -> { s | title = f.location, body = f.location, type_ = f.filetype }
                , Cmd.none
                )

        FileUploadFailed slide error ->
            Debug.log (toString error) ( model, Cmd.none )


updateSlide : Models.Slides.SlideModel -> (Slide -> Slide) -> Models.Slides.SlideModel
updateSlide model fn =
    { model | slide = (fn model.slide) }


setSlide : Slides -> SlideModel -> Slides
setSlide slides newSlide =
    let
        compare newSlide slide =
            if newSlide.slide.id == slide.slide.id then
                newSlide
            else
                slide
    in
        { slides | slides = List.map (compare newSlide) slides.slides }


setEditSlide : Slides -> SlideModel -> Slides
setEditSlide slides slide =
    { slides | newSlide = Maybe.map (\popupState -> { popupState | data = slide }) slides.newSlide }


view : Slides -> List (Html Msg)
view model =
    viewNewSlide :: List.map Slide.Slide.view model.slides


viewNewSlide : Html Msg
viewNewSlide =
    li [ class "slide slide--new-slide", onClick NewSlide ]
        [ div [ class "slide__content slide__content--new-slide" ] []
        ]
