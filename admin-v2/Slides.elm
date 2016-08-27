module Slides exposing (..)

import Html exposing (Html, text, ul)
import Html.App as App
import Html.App exposing (map)
import Json.Decode exposing (Decoder, list)
import Http
import Task
import Slide
import Modal
import Debug exposing (log)

type alias Model =
    { slides : List Slide.Model
    , modal : Modal.Model
    }

init : (Model, Cmd Msg)
init =
    let
        (newModal, newModalCmd) = Modal.init
    in
        (Model [] newModal, Cmd.batch [Cmd.map NewSlideModal newModalCmd, getSlides])

type Msg
    = GetSlides
    | GetSucceeded ( List Slide.Model )
    | GetFailed Http.Error
    | Slide Slide.Model Slide.Msg
    | NewSlideModal Modal.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    log ("Slides: " ++ toString msg) <|
    case msg of
        GetSlides ->
            (model, getSlides)

        GetSucceeded newSlides ->
            ({model | slides = newSlides}, Cmd.none)

        GetFailed error ->
            (model, Cmd.none)

        Slide slide msg ->
            let
                (newModels, newCmds) = List.unzip (List.map (updateSlide slide msg) model.slides)
            in
                case msg of
                    Slide.Delete ->
                        ({model | slides = newModels}, Cmd.batch <| [getSlides] ++ newCmds)
                    Slide.Edit ->
                        editSlide model newModels slide
                    _ ->
                        ({model | slides = newModels}, Cmd.batch newCmds)

        NewSlideModal msg ->
            let
                (newModal, newModalCmd) = Modal.update msg model.modal
            in
                case msg of
                    Modal.CreateSucceeded _ ->
                        ( {model | modal = newModal}
                        , Cmd.batch [ Cmd.map NewSlideModal newModalCmd, getSlides ]
                        )
                    _ ->
                        ( { model | modal = newModal}
                        , Cmd.map NewSlideModal newModalCmd
                        )

updateSlide : Slide.Model -> Slide.Msg -> Slide.Model -> (Slide.Model, Cmd Msg)
updateSlide newModel msg currentModel =
    if newModel.id == currentModel.id then
        let
            (newSlide, newCmd) = Slide.update msg newModel
        in
            (newSlide, Cmd.map (Slide newSlide) newCmd)
    else
        (currentModel, Cmd.none)

editSlide : Model -> List Slide.Model -> Slide.Model -> (Model, Cmd Msg)
editSlide model newSlides slide =
    let
        (newModal, newModalCmd) = Modal.update (Modal.Edit slide) model.modal
    in
        ({model | slides = newSlides, modal = newModal}, Cmd.map NewSlideModal newModalCmd)

decoder : Decoder (List Slide.Model)
decoder = list Slide.decoder

getSlides : Cmd Msg
getSlides = Task.perform GetFailed GetSucceeded <| Http.get decoder "/slides"

subscriptions : Model -> Sub Msg
subscriptions model = Sub.map NewSlideModal <| Modal.subscriptions model.modal

view : Model -> List (Html Msg)
view model =
    let
        newSlide = App.map NewSlideModal <| Modal.view model.modal
    in
        newSlide :: List.map (\slide -> map (Slide slide) (Slide.view slide)) model.slides
