module Main exposing (..)

import Html exposing (..)
import Html exposing (program, map)
import Html.Attributes exposing (class)
import Http
import Models.Slides as Slides
import Time exposing (Time, second, millisecond)
import Models exposing (Model, Slides, SlideWrapper)


initModel : Model
initModel =
    Model (Slides.init [])


init : ( Model, Cmd Msg )
init =
    ( initModel, getSlides Slides )


type Msg
    = Slides (Result Http.Error (List SlideWrapper))
    | Refetch
    | RefetchSlides (Result Http.Error (List SlideWrapper))
    | SlidesMsg Slides.Msg


type alias SlidesResult =
    Result.Result Http.Error (List SlideWrapper) -> Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Slides (Ok slideList) ->
            ( Model (Slides.init slideList), Cmd.none )

        Slides (Err _) ->
            ( model, Cmd.none )

        Refetch ->
            ( model, getSlides RefetchSlides )

        RefetchSlides (Ok slideList) ->
            let
                s =
                    model.slides
            in
                ( { model | slides = { s | nextSlides = Just (Slides.fromList slideList) } }, Cmd.none )

        RefetchSlides (Err _) ->
            ( model, Cmd.none )

        SlidesMsg slidesMsg ->
            let
                ( newSlides, slidesCmd ) =
                    Slides.update slidesMsg model.slides

                mappedCmd =
                    Cmd.map SlidesMsg slidesCmd
            in
                ( { model | slides = newSlides }, mappedCmd )


getSlides : SlidesResult -> Cmd Msg
getSlides message =
    Http.send message <| Http.get "/data" Slides.slides


view : Model -> Html Msg
view model =
    div [ class "switcharoo" ]
        [ map (\_ -> Refetch) (Slides.view model.slides) ]


subscription : Model -> Sub Msg
subscription model =
    Sub.batch
        [ Time.every (10 * second) (\_ -> Refetch)
        , Sub.map SlidesMsg <| Slides.subscriptions model.slides
        ]


main : Program Never Model Msg
main =
    program { init = init, update = update, view = view, subscriptions = subscription }
