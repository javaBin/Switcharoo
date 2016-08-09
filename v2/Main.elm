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
    , nextSlides: Maybe Slides.Model
    , index: Int
    , class: String
    }

initModel : Model
initModel = Model (Slides.init) Nothing 0 ""

init : (Model, Cmd Msg)
init = (initModel, getSlides)

type Msg
    = GetSlides
    | GetSucceeded Slides.Model
    | GetFailed Http.Error
    | Refetch
    | RefetchSucceeded Slides.Model
    | RefetchFailed Http.Error
    | NextSlide
    | HideSlide
    | ShowSlide

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetSlides ->
            (model, getSlides)

        GetSucceeded slides ->
            (Model slides Nothing 0 "", Cmd.none)

        GetFailed error ->
            (model, Cmd.none)

        Refetch ->
            (model, refetchSlides)

        RefetchSucceeded slides ->
            if slides == model.slides then
                (model, Cmd.none)
            else
                ({ model | nextSlides = Just slides }, Cmd.none)

        RefetchFailed _ ->
            (model, Cmd.none)

        HideSlide ->
            let
                nextIndex = Slides.getNextIndex model.index model.slides
                hasNext = isJust model.nextSlides
            in
                if hasNext then
                    ({ model | class = "switcharoo--hidden" }, hideSlide)
                else if nextIndex == model.index then
                    (model, Cmd.none)
                else
                    ({ model | class = "switcharoo--hidden" }, hideSlide)

        NextSlide ->
            let
                nextIndex = Slides.getNextIndex model.index model.slides
            in
                if nextIndex == 0 then
                    swapIfNewSlides model
                else
                    ({ model | index = nextIndex }, showSlide)

        ShowSlide ->
            ({ model | class = "" }, Cmd.none)

isJust : Maybe a -> Bool
isJust m =
    case m of
        Just _ -> True
        Nothing -> False


swapIfNewSlides : Model -> (Model, Cmd Msg)
swapIfNewSlides model =
    case model.nextSlides of
        Just s -> ({ model | index = 0, slides = s, nextSlides = Nothing }, showSlide)
        Nothing -> ({ model | index = 0 }, showSlide)

getSlides : Cmd Msg
getSlides = Task.perform GetFailed GetSucceeded <| Http.get Slides.slides "/data"

refetchSlides : Cmd Msg
refetchSlides = Task.perform RefetchFailed RefetchSucceeded <| Http.get Slides.slides "/data"

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
subscription model =
    Sub.batch
        [ Time.every (5 * second) (\_ -> HideSlide)
        , Time.every (10 * second) (\_ -> Refetch)
        ]

main : Program Never
main = program { init = init, update = update, view = view, subscriptions = subscription}
