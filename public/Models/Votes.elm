module Models.Votes exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, int, (:=), object1)


type alias Model =
    { votes : Int
    }

init : Model
init = Model 0

type Msg = Update

decoder : Decoder Model
decoder = object1 Model ("votes" := int)

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

view : Model -> Html Msg
view model =
    div [ class "slides__slide votes " ]
        [ h1 [ class "votes__header" ] [ text "Remember to vote after talks! So far " ]
        , h1 [ class "votes__vote" ] [ text <| toString model.votes ]
        , h1 [ class "votes__header" ] [ text "has been given" ]
        ]
