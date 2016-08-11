module Models.Tweets exposing (Model, view)

import Html exposing (..)
-- import Html.Attributes exposing (class)
-- import Json.Decode.Extra exposing ((|:))
-- import Json.Decode exposing (Decoder, succeed)
import Models.Tweet as Tweet

type alias Model =
    { tweets : List Tweet.Model
    }

type Msg = Update

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

view : Model -> Html Msg
view model =
    div [] [ text "test" ]
