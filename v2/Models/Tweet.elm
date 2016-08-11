module Models.Tweet exposing (Model, view, tweet)

import Html exposing (..)
import Html.Attributes exposing (class, src)
import Json.Decode.Extra exposing ((|:))
import Json.Decode exposing (Decoder, succeed, string, (:=))

type alias Model =
    { user : String
    , text : String
    , image : String
    }

type Msg = Update

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

tweet : Decoder Model
tweet =
    succeed Model
        |: ("user" := string)
        |: ("text" := string)
        |: ("image" := string)

view : Model -> Html Msg
view model =
    div [ class "twitter__tweet tweet" ]
        [ img [ class "tweet__img", src model.image ] []
        , span [ class "tweet__user" ] [ text model.user ]
        , span [ class "tweet__body" ] [ text model.text ]
        ]
