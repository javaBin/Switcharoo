module Main exposing (..)

import Html exposing (..)
import Html exposing (map)
import Navigation
import Nav exposing (hashParser)
import Http
import Models.Slides as Slides
import Time exposing (Time, second, millisecond)
import Models exposing (Model, Data, SlideWrapper, Flags, Settings)
import Decoder.Data
import Decoder.Conferences
import Messages exposing (Msg(..))
import WebSocket
import Models.Page exposing (Page(..))
import View.Conferences
import View.Conference


initModel : Flags -> Page -> Model
initModel flags page =
    Model (Slides.init []) Nothing (Settings flags.host) [] page


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        page =
            hashParser location

        model =
            initModel flags page

        ( newModel, cmd ) =
            pageChanged model page
    in
        ( newModel, cmd )


type alias SlidesResult =
    Result.Result Http.Error Data -> Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Slides (Ok data) ->
            ( Model (Slides.init data.slides) data.overlay model.settings [] model.page, Cmd.none )

        Slides (Err _) ->
            ( model, Cmd.none )

        Refetch conference ->
            ( model, getSlides (toString conference) RefetchSlides )

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

        WSMessage message ->
            case model.page of
                Conferences ->
                    ( model, Cmd.none )

                Conference n ->
                    ( model, parseWebsocketMessage model.settings n message )

        PageChanged page ->
            pageChanged model page

        GotConferences (Ok conferences) ->
            ( { model | conferences = conferences }, Cmd.none )

        GotConferences (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )


parseWebsocketMessage : Settings -> Int -> String -> Cmd msg
parseWebsocketMessage settings conference message =
    case message of
        "WELCOME:" ->
            Cmd.batch
                [ WebSocket.send (wsUrl settings) <| "CONFERENCE:" ++ toString conference
                , WebSocket.send (wsUrl settings) "REGISTER:PUBLIC"
                ]

        _ ->
            Cmd.none


pageChanged : Model -> Page -> ( Model, Cmd Msg )
pageChanged model page =
    case page of
        Conferences ->
            ( { model | page = page }, getConferences )

        Conference c ->
            ( { model | page = page }, getSlides (toString c) Slides )


getSlides : String -> SlidesResult -> Cmd Msg
getSlides conference message =
    Http.send message <| Http.get ("/data/" ++ conference) Decoder.Data.decoder


getConferences : Cmd Msg
getConferences =
    Http.send GotConferences <| Http.get "/data" Decoder.Conferences.decoder


view : Model -> Html Msg
view model =
    case model.page of
        Conferences ->
            View.Conferences.view model

        Conference _ ->
            View.Conference.view model


subscription : Model -> Sub Msg
subscription model =
    case model.page of
        Conferences ->
            Sub.none

        Conference c ->
            Sub.batch
                [ Time.every (10 * second) (\_ -> Refetch c)
                , Sub.map SlidesMsg <| Slides.subscriptions model.slides
                , WebSocket.listen (wsUrl model.settings) WSMessage
                ]


wsUrl : Settings -> String
wsUrl settings =
    "ws://" ++ settings.host ++ "/websocket"


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (PageChanged << hashParser) { init = init, update = update, view = view, subscriptions = subscription }
