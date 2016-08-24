module Models.Slot exposing (Model, view, decoder)

import Html exposing (..)
import Html.Attributes exposing (class)
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

unwrapMaybe : Maybe String -> String
unwrapMaybe m =
    case m of
        Just s  -> s
        Nothing -> ""

view : Model -> Html Msg
view model =
    li [ class "program__entry entry"]
       [ div [ class "entry__room" ]
             [ text model.room ]
       , div [ class "entry__info" ]
             [ div [ class "entry__title" ]
                   [ text model.title]
             , div [ class "entry__speakers" ]
                   [ text <| unwrapMaybe model.speakers ]
             ]
       ]
