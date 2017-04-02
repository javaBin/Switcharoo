module Service.Service exposing (..)

import Service.Model exposing (..)
import Service.Messages exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder, Value, succeed, string, bool, field, int)
import Json.Decode.Extra exposing ((|:))
import Json.Encode as Encode
import Http
import Backend exposing (toggleSetting)


init : ( Model, Cmd Msg )
init =
    ( Model -1 "" False, Cmd.none )


decoder : Decoder Model
decoder =
    succeed Model
        |: field "id" int
        |: field "key" string
        |: field "value" bool


encoder : Model -> Value
encoder model =
    Encode.object
        [ ( "id", Encode.int model.id )
        , ( "key", Encode.string model.key )
        , ( "value", Encode.bool model.value )
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Toggle ->
            let
                newModel =
                    { model | value = not model.value }
            in
                ( newModel, toggleSetting newModel )

        Toggled (Err _) ->
            ( { model | value = not model.value }, Cmd.none )

        Toggled (Ok _) ->
            ( model, Cmd.none )


label : Model -> String
label model =
    case model.key of
        "twitter-enabled" ->
            "Twitter"

        "instagram-enabled" ->
            "Instagram"

        "program-enabled" ->
            "Program"

        "votes-enabled" ->
            "Votes"

        _ ->
            "Error"


icon : String -> Html msg
icon c =
    i [ class <| "service-list__icon icon-" ++ c ] []


view : Model -> Html Msg
view model =
    li [ class "service-list__service" ]
        [ button
            [ classList [ ( "service-list__toggle", True ), ( "service-list__toggle--enabled", model.value ) ]
            , onClick Toggle
            ]
            [ icon <|
                if model.value then
                    "check"
                else
                    "close"
            , text <| label model
            ]
        ]
