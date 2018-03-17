module Service.Service exposing (..)

import Service.Model exposing (..)
import Service.Messages exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder, Value, succeed, string, bool, field, int)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Backend exposing (toggleService)
import Models.Conference exposing (Conference)


init : ( Model, Cmd Msg )
init =
    ( Model -1 "" False, Cmd.none )


encoder : Model -> Value
encoder model =
    Encode.object
        [ ( "id", Encode.int model.id )
        , ( "key", Encode.string model.key )
        , ( "value", Encode.bool model.value )
        ]


update : Conference -> Msg -> Model -> ( Model, Cmd Msg )
update conference msg model =
    case msg of
        Toggle ->
            let
                newModel =
                    { model | value = not model.value }
            in
                ( newModel, toggleService conference newModel )

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
    li [ class "slide slide--special" ]
        [ button
            [ classList [ ( "slide__content", True ), ( "slide__content--visible", model.value ) ]
            , onClick Toggle
            ]
            [ div [ class "slide__title" ] [ text <| label model ]
            ]
        ]
