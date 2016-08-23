module Models.Program exposing (Model, view, decoder)

import Html exposing (..)
import Json.Decode exposing (Decoder, list, object2, (:=), string)
import Models.Slot as Slot

type alias Model =
    { presentations : List Slot.Model
    , heading : String
    }

type Msg = Update

decoder : Decoder Model
decoder = object2 Model ("presentations" := list Slot.decoder) ("heading" := string)

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

view : Model -> Html Msg
view model =
    div [] [ text "program" ]
