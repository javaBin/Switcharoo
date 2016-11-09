module Main exposing (..)

import Html exposing (..)
import Html.App exposing (program, map)
import Html.Attributes exposing (class)
import Http
import Task
import Models.Slides as Slides
import Time exposing (Time, second, millisecond)
import Debug


type alias Model =
    { slides : Slides.Model
    , nextSlides : Maybe Slides.Model
    }


initModel : Model
initModel =
    Model (Slides.init) Nothing


init : ( Model, Cmd Msg )
init =
    ( initModel, getSlides )


type Msg
    = GetSlides
    | GetSucceeded (List Slides.SlideWrapper)
    | GetFailed Http.Error
    | Refetch
    | RefetchSucceeded (List Slides.SlideWrapper)
    | RefetchFailed Http.Error
    | SlidesMsg Slides.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetSlides ->
            ( model, getSlides )

        GetSucceeded slideList ->
            ( Model (Slides.fromList slideList) Nothing, Cmd.none )

        GetFailed error ->
            ( model, Cmd.none )

        Refetch ->
            ( model, refetchSlides )

        RefetchSucceeded slideList ->
            if (Slides.fromList slideList).slides == model.slides.slides then
                Debug.log "content is equal" ( model, Cmd.none )
            else
                Debug.log "content is different" ( { model | nextSlides = Just (Slides.fromList slideList) }, Cmd.none )

        RefetchFailed _ ->
            ( model, Cmd.none )

        SlidesMsg slidesMsg ->
            let
                ( newSlides, slidesCmd ) =
                    Slides.update slidesMsg model.slides

                mappedCmd =
                    Cmd.map SlidesMsg slidesCmd

                slides =
                    Slides.updateIfPossible newSlides model.nextSlides
            in
                ( { model | slides = slides }, mappedCmd )


getSlides : Cmd Msg
getSlides =
    Task.perform GetFailed GetSucceeded <| Http.get Slides.slides "/data"


refetchSlides : Cmd Msg
refetchSlides =
    Task.perform RefetchFailed RefetchSucceeded <| Http.get Slides.slides "/data"


view : Model -> Html Msg
view model =
    div [ class "switcharoo" ]
        [ map (\_ -> GetSlides) (Slides.view model.slides) ]


subscription : Model -> Sub Msg
subscription model =
    Sub.batch
        [ Time.every (10 * second) (\_ -> Refetch)
        , Sub.map SlidesMsg <| Slides.subscriptions model.slides
        ]


main : Program Never
main =
    program { init = init, update = update, view = view, subscriptions = subscription }
