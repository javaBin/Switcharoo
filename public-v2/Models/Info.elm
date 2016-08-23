module Models.Info exposing (Model, view, info)

import Html exposing (..)
import Html.Attributes exposing (class, style, attribute, src)
import Json.Decode.Extra exposing((|:))
import Json.Decode exposing (Decoder, decodeValue, succeed, string, int, andThen, maybe, (:=))
import String exposing (toInt)

type alias Model =
    { title : String
    , body : String
    , index: Int
    , slideType : InfoType
    }

type Msg = Update

type InfoType = TextInfo | ImageInfo | VideoInfo

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

info : Decoder Model
info =
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

decodeType : String -> Decoder InfoType
decodeType t =
    case t of
        "text" -> succeed TextInfo
        "image" -> succeed ImageInfo
        _ -> succeed VideoInfo

view : Model -> Html Msg
view model =
    case model.slideType of
        TextInfo -> textView model
        ImageInfo -> imageView model
        VideoInfo -> videoView model

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

videoView : Model -> Html Msg
videoView model =
    div [ class "slides__slide slide slide--video" ]
        [ video [ attribute "autoplay" "true", src model.body ]
                []
        ]
