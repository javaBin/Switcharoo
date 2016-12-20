module Setting exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder, Value, succeed, string, bool, field, int)
import Json.Decode.Extra exposing ((|:))
import Json.Encode as Encode
import Http


type alias Model =
    { id : Int
    , key : String
    , value : Bool
    }


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


type Msg
    = Toggle
    | Toggled (Result Http.Error String)


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


toggleSetting : Model -> Cmd Msg
toggleSetting model =
    Http.send Toggled <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "Content-Type" "application/json" ]
            , url = "/settings/" ++ toString model.id
            , body = Http.emptyBody
            , expect = Http.expectString
            , timeout = Nothing
            , withCredentials = False
            }


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
    i [ class <| "setting__icon icon-" ++ c ] []


view : Model -> Html Msg
view model =
    li [ class "settings__setting" ]
        [ button
            [ classList [ ( "settings__toggle", True ), ( "settings__toggle--enabled", model.value ) ]
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
