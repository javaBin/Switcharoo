module Models.Slides exposing (Model, view, slides, init, getNextIndex)

import Html.App as App
import List exposing (length)
import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, andThen, succeed, list, string, object1, fail, (:=))
import Models.Info as Info
import Models.Tweets as Tweets
import Models.Program as Program

type alias Model =
    { slides : List SlideWrapper
    }

init : Model
init = Model []

type SlideWrapper
    = InfoWrapper Info.Model
    | TweetsWrapper Tweets.Model
    | ProgramWrapper Program.Model

type Msg
    = Update

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

slides : Decoder Model
slides = object1 Model ("slides" := slideWrapperList)

slideWrapperList : Decoder (List SlideWrapper)
slideWrapperList = list (("type" := string) `andThen` slideWrapper)

slideWrapper : String -> Decoder SlideWrapper
slideWrapper t =
    case t of
        "text" -> Info.info `andThen` (\s -> succeed <| InfoWrapper s)
        "image" -> Info.info `andThen` (\s -> succeed <| InfoWrapper s)
        "video" -> Info.info `andThen` (\s -> succeed <| InfoWrapper s)
        "tweets" -> Tweets.tweets `andThen` (\s -> succeed <| TweetsWrapper s)
        "program" -> Program.decoder `andThen` (\s -> succeed <| ProgramWrapper s)
        t' -> fail <| "Unknown slideType " ++ t'

view : Model -> Int -> Html Msg
view model idx =
    let
        slide = getAt idx model.slides
    in
        case slide of
            Just s -> viewSlide s
            Nothing -> div [ class "slides" ] [ text "" ]

viewSlide : SlideWrapper -> Html Msg
viewSlide slide =
    case slide of
        InfoWrapper s -> App.map (\_ -> Update) (Info.view s)
        TweetsWrapper s -> App.map (\_ -> Update) (Tweets.view s)
        ProgramWrapper s -> App.map (\_ -> Update) (Program.view s)

getAt : Int -> List a -> Maybe a
getAt idx = List.head << List.drop idx

getNextIndex : Int -> Model -> Int
getNextIndex idx model =
    if idx + 1 == length model.slides then
        0
    else
        idx + 1
