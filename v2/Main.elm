import Html exposing (..)
import Html.App exposing (program, map)
import Html.Attributes exposing (class)
import Http
import Task
import Slides
import Time exposing (Time, second, millisecond)
import Process exposing (sleep)

type alias Model =
    { slides : Slides.Model
    , index: Int
    , class: String
    }

initModel : Model
initModel = Model (Slides.init) 0 ""

init : (Model, Cmd Msg)
init = (initModel, getSlides)

type Msg
    = GetSlides
    | GetSucceeded Slides.Model
    | GetFailed Http.Error
    | NextSlide
    | HideSlide
    | ShowSlide

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetSlides -> (model, getSlides)

        GetSucceeded slides ->
            (Model slides 0 "", Cmd.none)

        GetFailed error ->
            (model, Cmd.none)

        HideSlide ->
            ({ model | class = "switcharoo--hidden" }, hideSlide)

        NextSlide ->
            ({ model | index = Slides.getNextIndex model.index model.slides }, showSlide)

        ShowSlide ->
            ({ model | class = "" }, Cmd.none)

getSlides : Cmd Msg
getSlides = Task.perform GetFailed GetSucceeded <| Http.get Slides.slides "/data"

hideSlide : Cmd Msg
hideSlide = Task.perform (\_ -> NextSlide) (\_ -> NextSlide) <| sleep (500 * millisecond)

showSlide : Cmd Msg
showSlide = Task.perform (\_ -> ShowSlide) (\_ -> ShowSlide) <| sleep (500 * millisecond)

view : Model -> Html Msg
view model =
    let
        slides = map (\_ -> GetSlides) (Slides.view model.slides model.index)
        class' = "switcharoo " ++ model.class
    in
        div [ class class' ]
            [ slides ]

subscription : model -> Sub Msg
subscription model = Time.every (5 * second) (\_ -> HideSlide)

main : Program Never
main = program { init = init, update = update, view = view, subscriptions = subscription}
