module Models.Tweet exposing (Model, view, tweet)

import Html exposing (Html, div, li, text, span)
import Html.Attributes exposing (class, style)
import Json.Decode.Extra exposing ((|:))
import Json.Decode exposing (Decoder, succeed, string, field)
import Combine as C
import String


type alias Model =
    { user : String
    , text : String
    , image : String
    , handle : String
    }


type Msg
    = Update


update : Msg -> Model -> Model
update msg model =
    case msg of
        Update ->
            model


tweet : Decoder Model
tweet =
    succeed Model
        |: (field "user" string)
        |: (field "text" string)
        |: (field "image" string)
        |: (field "handle" string)


type T
    = Text String
    | At String
    | Hash String


tText : C.Parser s T
tText =
    C.map Text (C.regex "[^@#]+")


tAt : C.Parser s T
tAt =
    C.map At (C.regex "@\\w+")


tHash : C.Parser s T
tHash =
    C.map Hash (C.regex "#\\w+")


tTweet : C.Parser s (List T)
tTweet =
    C.lazy <| \() -> C.many (C.choice [ tText, tAt, tHash ])


parseTweet : String -> Result String (List T)
parseTweet tweet =
    case C.parse tTweet tweet of
        Ok ( _, _, res ) ->
            Ok res

        Err ( _, _, errors ) ->
            Err <| String.join " or " errors


view : Model -> Html Msg
view model =
    case parseTweet model.text of
        Ok tweet ->
            tweetView model tweet

        Err _ ->
            div [] []


tweetView : Model -> List T -> Html Msg
tweetView model t =
    let
        body =
            List.map toHtml t
    in
        li [ class "tweets__tweet tweet" ]
            [ div [ class "tweet__info" ]
                [ div
                    [ style [ ( "backgroundImage", "url('" ++ model.image ++ "')" ) ]
                    , class "tweet__img"
                    ]
                    []
                , div [ class "tweet__user" ]
                    [ div [ class "tweet__name" ]
                        [ text model.user ]
                    , div [ class "tweet__handle" ]
                        [ text <| "@" ++ model.handle ]
                    ]
                ]
            , div [ class "tweet__body" ] body
            ]


toHtml : T -> Html Msg
toHtml t =
    case t of
        Text s ->
            textView s

        At s ->
            atView s

        Hash s ->
            hashView s


textView : String -> Html Msg
textView s =
    span [ class "tweet__text" ] [ text s ]


atView : String -> Html Msg
atView s =
    span [ class "tweet__at" ] [ text s ]


hashView : String -> Html Msg
hashView s =
    span [ class "tweet__hash" ] [ text s ]
