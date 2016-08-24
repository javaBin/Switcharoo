module Models.Tweets exposing (Model, view, tweets)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App as App
import List
import Json.Decode exposing (Decoder, list, object1, (:=))
import Models.Tweet as Tweet

type alias Model =
    { tweets : List Tweet.Model
    }

type Msg = Update

tweets : Decoder Model
tweets = object1 Model ("tweets" := list Tweet.tweet)

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

view : Model -> Html Msg
view model =
    let
        tweets = List.map (\tweet -> App.map (\_ -> Update) (Tweet.view tweet)) model.tweets
    in
        ul [ class "slides__slide tweets" ]
            tweets
