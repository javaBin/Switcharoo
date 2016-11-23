module Models.Info exposing (Model, view, info, empty)

import Html exposing (..)
import Html.Attributes exposing (class, style, attribute, src)
import Json.Decode.Extra exposing ((|:))
import Json.Decode exposing (Decoder, decodeValue, succeed, string, int, andThen, maybe, field)
import String exposing (toInt)


type alias Model =
    { title : String
    , body : String
    , index : Int
    , slideType : InfoType
    }


type Msg
    = Update


type InfoType
    = TextInfo
    | ImageInfo
    | VideoInfo


empty : Model
empty =
    Model "" "" 0 TextInfo


update : Msg -> Model -> Model
update msg model =
    case msg of
        Update ->
            model


info : Decoder Model
info =
    succeed Model
        |: (field "title" string)
        |: (field "body" string)
        |: ((field "index" string) |> andThen decodeIndex)
        |: ((field "type" string) |> andThen decodeType)


decodeIndex : String -> Decoder Int
decodeIndex n =
    case toInt n of
        Ok number ->
            succeed number

        Err _ ->
            succeed 0


decodeType : String -> Decoder InfoType
decodeType t =
    case t of
        "text" ->
            succeed TextInfo

        "image" ->
            succeed ImageInfo

        _ ->
            succeed VideoInfo


view : Model -> Html Msg
view model =
    case model.slideType of
        TextInfo ->
            textView model

        ImageInfo ->
            imageView model

        VideoInfo ->
            videoView model


textView : Model -> Html Msg
textView model =
    div [ class "slides__slide slide" ]
        [ h1 [ class "slide__title" ] [ text model.title ]
        , div [ class "slide__body" ] [ text model.body ]
        ]


imageView : Model -> Html Msg
imageView model =
    let
        style_ =
            [ ( "background-image", "url(" ++ model.body ++ ")" ) ]
    in
        div [ class "slides__slide slide slide--image" ]
            [ div [ class "slide__image", style style_ ] []
            ]


videoView : Model -> Html Msg
videoView model =
    div [ class "slides__slide slide slide--video" ]
        [ video
            [ src model.body
            , attribute "autoplay" "true"
            , attribute "loop" "true"
            , class "slide__video"
            ]
            []
        ]
