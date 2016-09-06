import Html exposing (..)
import Html.App exposing (program, map)
import Html.Attributes exposing (class)
import Http
import Task
import Models.Slides as Slides
import Time exposing (Time, second, millisecond)
import Process exposing (sleep)

type alias Model =
    { slides : Slides.Model
    , nextSlides: Maybe Slides.Model
    , index: Int
    , switching: Bool
    }

initModel : Model
initModel = Model (Slides.init) Nothing 0 False

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
    | SlidesMsg Slides.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetSlides ->
            (model, getSlides)

        GetSucceeded slides ->
            (Model slides Nothing 0 False, Cmd.none)

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
                    ({ model | switching = True }, hideSlide)
                else if nextIndex == model.index then
                    (model, Cmd.none)
                else
                    ({ model | switching = True }, hideSlide)

        NextSlide ->
            let
                nextIndex = Slides.getNextIndex model.index model.slides
                newVotes = Slides.update Slides.ResetVotes model.slides
            in
                if nextIndex == 0 then
                    swapIfNewSlides model
                else
                    ({ model | index = nextIndex, slides = newVotes }, showSlide)

        ShowSlide ->
            ({ model | switching = False }, Cmd.none)

        SlidesMsg slidesMsg ->
            let
                newSlides = Slides.update slidesMsg model.slides
            in
                ({model | slides = newSlides}, Cmd.none)

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
        class' = containerClass model
    in
        div [ class class' ]
            [ slides ]

containerClass : Model -> String
containerClass model =
    if model.switching then
        "switcharoo switcharoo--hidden"
    else
        "switcharoo"

subscription : Model -> Sub Msg
subscription model =
    Sub.batch
        [ Time.every (10 * second) (\_ -> HideSlide)
        , Time.every (60 * second) (\_ -> Refetch)
        , Sub.map SlidesMsg <| Slides.subscriptions model.slides
        ]

main : Program Never
main = program { init = init, update = update, view = view, subscriptions = subscription}
