module Models.Tweets exposing (Model, view, tweets)

import Html exposing (Html, ul)
import Html.Attributes exposing (class)
import List
import Json.Decode exposing (Decoder, list, map, field)
import Models.Tweet as Tweet


type alias Model =
    { tweets : List Tweet.Model
    }


type Msg
    = Update


tweets : Decoder Model
tweets =
    map Model (field "tweets" <| list Tweet.tweet)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Update ->
            model


view : Model -> Html Msg
view model =
    let
        tweets =
            List.map (\tweet -> Html.map (\_ -> Update) (Tweet.view tweet)) model.tweets
    in
        ul [ class "slides__slide tweets" ]
            tweets
