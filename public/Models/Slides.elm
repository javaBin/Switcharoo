module Models.Slides exposing (..)

import Html exposing (Html)
import List exposing (length)
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Json.Decode exposing (Decoder, andThen, succeed, list, string, map, fail, field)
import Models.Info as Info
import Models.Tweets as Tweets
import Models.Program as Program
import Time exposing (Time, second, millisecond)
import Task
import Process exposing (sleep)
import List.Zipper exposing (Zipper, withDefault, first, next, current, toList)


type alias Model =
    { switching : Bool
    , slides : Zipper SlideWrapper
    }


init : Model
init =
    fromList []


fromList : List SlideWrapper -> Model
fromList =
    Model False << withDefault (InfoWrapper Info.empty) << List.Zipper.fromList


type SlideWrapper
    = InfoWrapper Info.Model
    | TweetsWrapper Tweets.Model
    | ProgramWrapper Program.Model


type Msg
    = NextSlide
    | HideSlide
    | ShowSlide


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HideSlide ->
            let
                shouldChange =
                    zipperLength model.slides > 1
            in
                if shouldChange then
                    ( { model | switching = True }, hideSlide )
                else
                    ( model, Cmd.none )

        NextSlide ->
            case (next model.slides) of
                Just z ->
                    ( { model | slides = z }, showSlide )

                Nothing ->
                    ( { model | slides = first model.slides }, showSlide )

        ShowSlide ->
            ( { model | switching = False }, Cmd.none )


hideSlide : Cmd Msg
hideSlide =
    Task.perform (\_ -> NextSlide) <| sleep (500 * millisecond)


showSlide : Cmd Msg
showSlide =
    Task.perform (\_ -> ShowSlide) <| sleep (500 * millisecond)


slides : Decoder (List SlideWrapper)
slides =
    field "slides" slideWrapperList


slideWrapperList : Decoder (List SlideWrapper)
slideWrapperList =
    list <| andThen slideWrapper <| field "type" string


slideWrapper : String -> Decoder SlideWrapper
slideWrapper t =
    case t of
        "text" ->
            Info.info |> andThen (succeed << InfoWrapper)

        "image" ->
            Info.info |> andThen (succeed << InfoWrapper)

        "video" ->
            Info.info |> andThen (succeed << InfoWrapper)

        "tweets" ->
            Tweets.tweets |> andThen (succeed << TweetsWrapper)

        "program" ->
            Program.decoder |> andThen (succeed << ProgramWrapper)

        unknown ->
            fail <| "Unknown slideType " ++ unknown


view : Model -> Html Msg
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every (10 * second) (\_ -> HideSlide)


updateIfPossible : Model -> Maybe Model -> ( Model, Maybe Model )
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
