-- module Slides exposing (Model, Msg, init, update, view, getSlides, GetSlides)
module Slides exposing (..)

import Html exposing (Html, text, ul)
import Html.App exposing (map)
import Json.Decode exposing (Decoder, list)
import Http
import Task
import Slide
import Debug exposing (log)

type alias Model =
    { slides : List Slide.Model
    }

init : (Model, Cmd Msg)
init = (Model [], getSlides)

type Msg
    = GetSlides
    | GetSucceeded ( List Slide.Model )
    | GetFailed Http.Error
    | Slide Slide.Model Slide.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    log ("Slides: " ++ toString msg) <|
    case msg of
        GetSlides ->
            (model, getSlides)

        GetSucceeded slides ->
            (Model slides, Cmd.none)

        GetFailed error ->
            (model, Cmd.none)

        Slide slide msg ->
            let
                (newModels, newCmds) = List.unzip (List.map (editSlide slide msg) model.slides)
            in
                if msg == Slide.Delete then
                    ({model | slides = newModels}, Cmd.batch <| [getSlides] ++ newCmds)
                else
                    ({model | slides = newModels}, Cmd.batch newCmds)

editSlide : Slide.Model -> Slide.Msg -> Slide.Model -> (Slide.Model, Cmd Msg)
editSlide newModel msg currentModel =
    if newModel.id == currentModel.id then
        let
            (newSlide, newCmd) = Slide.update msg newModel
        in
            (newSlide, Cmd.map (Slide newSlide) newCmd)
    else
        (currentModel, Cmd.none)

decoder : Decoder (List Slide.Model)
decoder = list Slide.decoder

getSlides : Cmd Msg
getSlides = Task.perform GetFailed GetSucceeded <| Http.get decoder "/slides"


view : Model -> List (Html Msg)
view model =
    List.map (\slide -> map (Slide slide) (Slide.view slide)) model.slides
