module Models.Slides exposing (..)

import Html exposing (Html)
import List exposing (length)
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Models.Info as Info
import Models.Tweets as Tweets
import Models.Program as Program
import Time exposing (Time, second, millisecond)
import Task
import Process exposing (sleep)
import List.Zipper exposing (Zipper, withDefault, first, next, current, toList)
import Models exposing (Slides, SlideWrapper(..))
import Keyboard


init : List SlideWrapper -> Slides
init =
    Slides False Nothing << fromList


fromList : List SlideWrapper -> Zipper SlideWrapper
fromList =
    withDefault (InfoWrapper Info.empty) << List.Zipper.fromList


type Msg
    = NextSlide
    | HideSlide
    | ShowSlide
    | Keypress Keyboard.KeyCode


update : Msg -> Slides -> ( Slides, Cmd Msg )
update msg model =
    case msg of
        HideSlide ->
            let
                shouldChange =
                    zipperLength model.slides > 1
            in
                if shouldChange || isNew model.slides model.nextSlides then
                    ( { model | switching = True }, hideSlide )
                else
                    ( model, Cmd.none )

        NextSlide ->
            nextSlide model

        ShowSlide ->
            ( { model | switching = False }, Cmd.none )

        Keypress code ->
            case code of
                39 ->
                    nextSlide model

                _ ->
                    ( model, Cmd.none )


nextSlide : Slides -> ( Slides, Cmd Msg )
nextSlide slides =
    case next slides.slides of
        Just z ->
            ( { slides | slides = z }, showSlide )

        Nothing ->
            case slides.nextSlides of
                Just n ->
                    ( { slides | slides = n, nextSlides = Nothing }, showSlide )

                Nothing ->
                    ( { slides | slides = first slides.slides }, showSlide )


hideSlide : Cmd Msg
hideSlide =
    Task.perform (\_ -> NextSlide) <| sleep (500 * millisecond)


showSlide : Cmd Msg
showSlide =
    Task.perform (\_ -> ShowSlide) <| sleep (500 * millisecond)


view : Slides -> Html Msg
view model =
    let
        slide =
            current model.slides
    in
        div [ classList [ ( "switcharoo", True ), ( "switcharoo--hidden", model.switching ) ] ]
            [ viewSlide slide ]


viewSlide : SlideWrapper -> Html Msg
viewSlide slide =
    case slide of
        InfoWrapper s ->
            Html.map (\_ -> NextSlide) (Info.view s)

        TweetsWrapper s ->
            Html.map (\_ -> NextSlide) (Tweets.view s)

        ProgramWrapper s ->
            Html.map (\_ -> NextSlide) (Program.view s)


subscriptions : Slides -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every (10 * second) (\_ -> HideSlide)
        , Keyboard.ups Keypress
        ]


updateIfPossible : Slides -> Maybe Slides -> ( Slides, Maybe Slides )
updateIfPossible current new =
    case next current.slides of
        Just _ ->
            ( current, new )

        Nothing ->
            case new of
                Just n ->
                    ( n, Nothing )

                Nothing ->
                    ( current, Nothing )


zipperLength : Zipper a -> Int
zipperLength =
    length << toList


zipperEquals : Zipper a -> Zipper a -> Bool
zipperEquals a b =
    toList a == toList b


isNew : Zipper SlideWrapper -> Maybe (Zipper SlideWrapper) -> Bool
isNew n m =
    case m of
        Just new ->
            if n == new then
                False
            else
                True

        Nothing ->
            False
