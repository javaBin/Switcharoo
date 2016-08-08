module Slide exposing (Model, view, slide)

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Json.Decode.Extra exposing((|:))
import Json.Decode exposing (Decoder, decodeValue, succeed, string, int, andThen, maybe, (:=))
import String exposing (toInt)

type alias Model =
    { title : String
    , body : String
    , index: Int
    , slideType : SlideType
    }

type Msg = Update

type SlideType = TextSlide | ImageSlide

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

slide : Decoder Model
slide =
    succeed Model
        |: ("title" := string)
        |: ("body" := string)
        |: (("index" := string) `andThen` decodeIndex)
        |: (("type" := string) `andThen` decodeType)

decodeIndex : String -> Decoder Int
decodeIndex n =
    case toInt n of
        Ok number -> succeed number
        Err _ -> succeed 0

decodeType : String -> Decoder SlideType
decodeType t = succeed <| if t == "text" then TextSlide else ImageSlide

view : Model -> Html Msg
view model =
    case model.slideType of
        TextSlide -> textView model
        ImageSlide -> imageView model

textView : Model -> Html Msg
textView model =
    div [ class "slides__slide slide" ]
        [ h1 [ class "slide__title" ] [ text model.title ]
        , div [ class "slide__body" ] [ text model.body ]
        ]

imageView : Model -> Html Msg
imageView model =
    let
        style' = [("background-image", "url(" ++ model.body ++ ")")]
    in
        div [ class "slides__slide slide slide--image" ]
            [ div [ class "slide__image", style style' ] []
            ]
