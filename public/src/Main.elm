module Main exposing (..)

import Html exposing (..)
import Html exposing (programWithFlags, map)
import Html.Attributes exposing (class)
import Http
import Models.Slides as Slides
import Time exposing (Time, second, millisecond)
import Models exposing (Model, Data, SlideWrapper, Flags)
import Decoder.Data
import SocketIO
import Messages exposing (Msg(..))
import View.Overlay


initModel : String -> Model
initModel conference =
    Model (Slides.init []) Nothing conference


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initModel flags.conference, Cmd.batch [ getSlides flags.conference Slides, SocketIO.connect <| flags.host ++ "/users" ] )


type alias SlidesResult =
    Result.Result Http.Error Data -> Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Slides (Ok data) ->
            ( Model (Slides.init data.slides) data.overlay model.conference, Cmd.none )

        Slides (Err _) ->
            ( model, Cmd.none )

        Refetch ->
            ( model, getSlides model.conference RefetchSlides )

        RefetchSlides (Ok data) ->
            let
                s =
                    model.slides
            in
                ( { model | slides = { s | nextSlides = Just (Slides.fromList data.slides) }, overlay = data.overlay }, Cmd.none )

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


getSlides : String -> SlidesResult -> Cmd Msg
getSlides conference message =
    Http.send message <| Http.get ("/data/" ++ conference) Decoder.Data.decoder


view : Model -> Html Msg
view model =
    div [ class "switcharoo" ]
        [ (View.Overlay.view model.overlay)
        , map SlidesMsg (Slides.view model.slides)
        ]


subscription : Model -> Sub Msg
subscription model =
    Sub.batch
        [ Time.every (10 * second) (\_ -> Refetch)
        , Sub.map SlidesMsg <| Slides.subscriptions model.slides
        ]


main : Program Flags Model Msg
main =
    programWithFlags { init = init, update = update, view = view, subscriptions = subscription }
