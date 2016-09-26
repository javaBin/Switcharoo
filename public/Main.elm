import Html exposing (..)
import Html.App exposing (program, map)
import Html.Attributes exposing (class)
import Http
import Task
import Models.Slides as Slides
import Time exposing (Time, second, millisecond)

type alias Model =
    { slides : Slides.Model
    , nextSlides: Maybe Slides.Model
    }

initModel : Model
initModel = Model (Slides.init) Nothing

init : (Model, Cmd Msg)
init = (initModel, getSlides)

type Msg
    = GetSlides
    | GetSucceeded (List Slides.SlideWrapper)
    | GetFailed Http.Error
    | Refetch
    | RefetchSucceeded (List Slides.SlideWrapper)
    | RefetchFailed Http.Error
    | SlidesMsg Slides.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetSlides ->
            (model, getSlides)

        GetSucceeded slideList ->
            (Model (Slides.Model slideList 0 False) Nothing, Cmd.none)

        GetFailed error ->
            (model, Cmd.none)

        Refetch ->
            (model, refetchSlides)

        RefetchSucceeded slideList ->
            if slideList == model.slides.slides then
                (model, Cmd.none)
            else
                ({ model | nextSlides = Just (Slides.Model slideList 0 False) }, Cmd.none)

        RefetchFailed _ ->
            (model, Cmd.none)

        SlidesMsg slidesMsg ->
            let
                (newSlides, slidesCmd) = Slides.update slidesMsg model.slides
                mappedCmd = Cmd.map SlidesMsg slidesCmd
            in
                if newSlides.index == 0 then
                    swapIfNewSlides model newSlides mappedCmd
                else
                    ({model | slides = newSlides}, mappedCmd)

isJust : Maybe a -> Bool
isJust m =
    case m of
        Just _ -> True
        Nothing -> False

swapIfNewSlides : Model -> Slides.Model -> Cmd Msg -> (Model, Cmd Msg)
swapIfNewSlides model newSlides slidesCmd =
    case model.nextSlides of
        Just s -> ({ model | slides = s, nextSlides = Nothing }, slidesCmd)
        Nothing -> ({ model | slides = newSlides }, slidesCmd)

getSlides : Cmd Msg
getSlides = Task.perform GetFailed GetSucceeded <| Http.get Slides.slides "/data"

refetchSlides : Cmd Msg
refetchSlides = Task.perform RefetchFailed RefetchSucceeded <| Http.get Slides.slides "/data"

view : Model -> Html Msg
view model =
    div [ class "switcharoo" ]
        [ map (\_ -> GetSlides) (Slides.view model.slides) ]

subscription : Model -> Sub Msg
subscription model =
    Sub.batch
        [ Time.every (60 * second) (\_ -> Refetch)
        , Sub.map SlidesMsg <| Slides.subscriptions model.slides
        ]

main : Program Never
main = program { init = init, update = update, view = view, subscriptions = subscription}
