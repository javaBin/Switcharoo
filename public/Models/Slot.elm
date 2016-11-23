module Models.Slot exposing (Model, view, decoder)

import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, map3, string, field, maybe)


type alias Model =
    { room : String
    , title : String
    , speakers : Maybe String
    }


type Msg
    = Update


decoder : Decoder Model
decoder =
    map3 Model (field "room" string) (field "title" string) (maybe (field "speakers" string))


update : Msg -> Model -> Model
update msg model =
    case msg of
        Update ->
            model


unwrapMaybe : Maybe String -> String
unwrapMaybe m =
    case m of
        Just s ->
            s

        Nothing ->
            ""


view : Model -> Html Msg
view model =
    li [ class "program__entry entry" ]
        [ div [ class "entry__room" ]
            [ text model.room ]
        , div [ class "entry__info" ]
            [ div [ class "entry__title" ]
                [ text model.title ]
            , div [ class "entry__speakers" ]
                [ text <| unwrapMaybe model.speakers ]
            ]
        ]
