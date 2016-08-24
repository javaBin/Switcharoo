module Models.Tweet exposing (Model, view, tweet)

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Json.Decode.Extra exposing ((|:))
import Json.Decode exposing (Decoder, succeed, string, (:=))

type alias Model =
    { user : String
    , text : String
    , image : String
    , handle : String
    }

type Msg = Update

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update -> model

tweet : Decoder Model
tweet =
    succeed Model
        |: ("user" := string)
        |: ("text" := string)
        |: ("image" := string)
        |: ("handle" := string)

view : Model -> Html Msg
view model =
    li [ class "tweets__tweet tweet" ]
        [ div [ style [("backgroundImage", "url('" ++ model.image ++ "')")], class "tweet__img" ] []
        , div [ class "tweet__info" ]
              [ div [ class "tweet__user" ]
                    [ div [ class "tweet__name" ]
                          [ text model.user ]
                    , div [ class "tweet__handle" ]
                          [ text model.handle ]
                    ]
              , div [ class "tweet__body" ] [ text model.text ]
              ]
        ]
