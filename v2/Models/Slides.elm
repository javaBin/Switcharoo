module Models.Slides exposing (Model, view, slides, init, getNextIndex)

import Html.App as App
import List exposing (length)
import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode.Extra exposing((|:))
import Json.Decode exposing (Decoder, decodeValue, succeed, list, (:=))
import Models.Slide as Slide

type alias Model =
    { info : List Slide.Model
    }

init : Model
init = Model []

type Msg
    = Update

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

slides : Decoder Model
slides =
    succeed Model
        |: ("info" := list Slide.slide)

view : Model -> Int -> Html Msg
view model idx =
    let
        slide = getAt idx model.info
    in
        case slide of
            Just s -> div [ class "slides" ] [ viewSlide s]
            Nothing -> div [ class "slides" ] [ text "" ]

viewSlide : Slide.Model -> Html Msg
viewSlide model = App.map (\_ -> Update) (Slide.view model)

getAt : Int -> List a -> Maybe a
getAt idx = List.head << List.drop idx

getNextIndex : Int -> Model -> Int
getNextIndex idx model =
    if idx + 1 == length model.info then
        0
    else
        idx + 1
