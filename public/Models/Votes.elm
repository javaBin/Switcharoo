module Models.Votes exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, int, (:=), object2)
import Time exposing (Time, second)

type alias Model =
    { votes : Int
    , realVotes : Int
    }

init : Model
init = Model 0 0

type Msg
    = Update Int
    | Reset

decoder : Decoder Model
decoder = object2 Model ("votes" := int) ("votes" := int)

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update i ->
            { model | votes = i }

        Reset ->
            {model | votes = model.realVotes}

subscriptions : Model -> Sub Msg
subscriptions model = Time.every (1 * second) (\_ -> Update (model.votes + 1))

view : Model -> Html Msg
view model =
    div [ class "slides__slide votes " ]
        [ h1 [ class "votes__header" ] [ text "Remember to vote after talks! So far " ]
        , h1 [ class "votes__vote" ] [ text <| toString model.votes ]
        , h1 [ class "votes__header" ] [ text "has been given" ]
        ]
