module Models.Slides exposing (Model, view, slides, init, getNextIndex)

import Html.App as App
import List exposing (length)
import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode.Extra exposing((|:), apply)
import Json.Decode exposing (Decoder, andThen, map, decodeValue, succeed, list, (:=))
import Models.Info as Info
import Models.Tweet as Tweet
import Models.Tweets as Tweets

-- type alias Model =
--     { info : List Info.Model
--     , tweets : List Tweet.Model
--     }

type alias Model =
    { slides : List SlideWrapper
    }

init : Model
init = Model [InfoWrapper []]

type SlideWrapper
    = InfoWrapper List Info.Model
    | TweetsWrapper List Tweets.Model

type Msg
    = Update

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

slides : Decoder Model
slides =
    andThen dataDecoder decodeModel


dataDecoder : (List Info.Model -> List Tweet.Model -> b) -> Decoder b
dataDecoder f = f
    `map` ("info" := list Info.info `andThen` decodeInfo)
    `apply` ("tweets" := list Tweet.tweet `andThen` decodeTweets)

decodeInfo : List Info.Model -> Decoder SlideWrapper
decodeInfo slides = succeed <| InfoWrapper slides

decodeTweets : List Tweet.Model -> Decoder SlideWrapper
decodeTweets tweets = succeed <| TweetsWrapper <| Tweets.Model tweets

decodeModel : SlideWrapper -> SlideWrapper -> Decoder Model
decodeModel s1 s2 = succeed <| Model  <| s1 ++ s2

view : Model -> Int -> Html Msg
view model idx =
    let
        slide = getAt idx model.info
    in
        case slide of
            Just s -> div [ class "slides" ] [ text "" ]
            Nothing -> div [ class "slides" ] [ text "" ]

-- viewSlide : Slide.Model -> Html Msg
-- viewSlide model = App.map (\_ -> Update) (Slide.view model)

getAt : Int -> List a -> Maybe a
getAt idx = List.head << List.drop idx

getNextIndex : Int -> Model -> Int
getNextIndex idx model =
    let
        num = length model.info + hasTweets model
    in
        if idx + 1 == num then
            0
        else
            idx + 1

hasTweets : Model -> Int
hasTweets model =
    case model.tweets of
        [] -> 0
        _  -> 1
