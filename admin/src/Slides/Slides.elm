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

        Move slide ->
            ( { model | moving = Just slide }, Cmd.none )

        CancelMove ->
            ( { model | moving = Nothing }, Cmd.none )

        Drop location ->
            let
                id =
                    Maybe.withDefault -1 <| Maybe.map (\s -> s.slide.id) model.moving

                oldLocation =
                    Maybe.withDefault location <| flatMap (\elem -> elemIndex elem model.slides) model.moving

                newLocation =
                    if location > oldLocation then
                        location - 1
                    else
                        location

                slidesWithoutMoving =
                    List.filter (\s -> s.slide.id /= id) model.slides

                newSlides =
                    case model.moving of
                        Nothing ->
                            model.slides

                        Just moving ->
                            List.take newLocation slidesWithoutMoving ++ [ moving ] ++ List.drop newLocation slidesWithoutMoving
            in
                ( { model | slides = newSlides, moving = Nothing }, Backend.updateIndexes conference <| List.map (.id << .slide) newSlides )

        IndexesUpdated (Ok _) ->
            ( model, Cmd.none )

        IndexesUpdated (Err err) ->
            Debug.log (toString err) ( model, Backend.getSlides conference )


elemIndex : a -> List a -> Maybe Int
elemIndex elem list =
    elemIndexHelp 0 elem list


elemIndexHelp : Int -> a -> List a -> Maybe Int
elemIndexHelp index elem list =
    case list of
        [] ->
            Nothing

        x :: xs ->
            if x == elem then
                Just index
            else
                elemIndexHelp (index + 1) elem xs


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
    let
        slides =
            List.map
                (\slide ->
                    Slide.Slide.view slide <|
                        Maybe.withDefault False <|
                            Maybe.map (\moving -> moving == slide) model.moving
                )
                model.slides

        moving =
            Maybe.withDefault False <| Maybe.map (\_ -> True) model.moving

        dropZones =
            List.map (Slide.Slide.viewDrop moving) <| List.range 1 <| List.length slides

        elements =
            List.foldr (++) [] <| List.map2 (\a b -> [ a, b ]) slides dropZones
    in
        Slide.Slide.viewDrop moving 0 :: elements


flatMap : (a -> Maybe b) -> Maybe a -> Maybe b
flatMap fn maybe =
    Maybe.map fn maybe |> joinMap


joinMap : Maybe (Maybe a) -> Maybe a
joinMap maybe =
    case maybe of
        Just a ->
            a

        Nothing ->
            Nothing
