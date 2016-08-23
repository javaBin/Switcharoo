module Models.Slot exposing (Model, view, decoder)

import Html exposing (..)
import Json.Decode exposing (Decoder, object3, string, (:=), maybe)

type alias Model =
    { room : String
    , title : String
    , speakers : Maybe String
    }

type Msg = Update

decoder : Decoder Model
decoder = object3 Model ("room" := string) ("title" := string) (maybe ("speakers" := string))

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

view : Model -> Html Msg
view model =
    div [] [ text model.title ]
