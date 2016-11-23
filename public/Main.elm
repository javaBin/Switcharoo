module Main exposing (..)

import Html exposing (..)
import Html exposing (program, map)
import Html.Attributes exposing (class)
import Http
import Models.Slides as Slides
import Time exposing (Time, second, millisecond)


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
    | Slides (Result Http.Error (List Slides.SlideWrapper))
    | Refetch
    | RefetchSlides (Result Http.Error (List Slides.SlideWrapper))
    | SlidesMsg Slides.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetSlides ->
            ( model, getSlides )

        Slides (Ok slideList) ->
            ( Model (Slides.fromList slideList) Nothing, Cmd.none )

        Slides (Err _) ->
            ( model, Cmd.none )

        Refetch ->
            ( model, refetchSlides )

        RefetchSlides (Ok slideList) ->
            if Slides.zipperEquals (Slides.fromList slideList).slides model.slides.slides then
                ( model, Cmd.none )
            else
                ( { model | nextSlides = Just (Slides.fromList slideList) }, Cmd.none )

        RefetchSlides (Err _) ->
            ( model, Cmd.none )

        SlidesMsg slidesMsg ->
            let
                ( newSlides, slidesCmd ) =
                    Slides.update slidesMsg model.slides

                mappedCmd =
                    Cmd.map SlidesMsg slidesCmd

                ( slides, nextSlides ) =
                    Slides.updateIfPossible newSlides model.nextSlides
            in
                ( { model | slides = slides, nextSlides = nextSlides }, mappedCmd )


getSlides : Cmd Msg
getSlides =
    Http.send Slides <| Http.get "/data" Slides.slides


refetchSlides : Cmd Msg
refetchSlides =
    Http.send RefetchSlides <| Http.get "/data" Slides.slides


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


main : Program Never Model Msg
main =
    program { init = init, update = update, view = view, subscriptions = subscription }
