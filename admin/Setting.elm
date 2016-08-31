module Setting exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder, Value, succeed, string, bool, (:=))
import Json.Decode.Extra exposing ((|:))
import Json.Encode as Encode
import Http exposing (Request, Response, Body, defaultSettings, send, empty)
import Task

type alias Model =
    { id : String
    , key : String
    , value : Bool
    }

init : (Model, Cmd Msg)
init = (Model "" "" False, Cmd.none)

decoder : Decoder Model
decoder =
    succeed Model
        |: ("_id" := string)
        |: ("key" := string)
        |: ("value" := bool)

encoder : Model -> Value
encoder model =
    Encode.object
        [ ("_id", Encode.string model.id)
        , ("key", Encode.string model.key)
        , ("value", Encode.bool model.value)
        ]

type Msg
    = Toggle
    | ToggleFailed Http.RawError
    | ToggleSucceeded Response

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Toggle ->
            let
                newModel = {model | value = not model.value}
            in
                (newModel, toggleSetting newModel)

        ToggleFailed _ ->
            ({model | value = not model.value}, Cmd.none)

        ToggleSucceeded _ ->
            (model, Cmd.none)

toggleRequest : Model -> Platform.Task Http.RawError Response
toggleRequest model =
    send defaultSettings
        { verb = "PUT"
        , headers = [("Content-Type", "application/json")]
        , url = "/settings/" ++ model.id
        , body = Http.string <| Encode.encode 0 <| encoder model
        }

toggleSetting : Model -> Cmd Msg
toggleSetting model = Task.perform ToggleFailed ToggleSucceeded <| toggleRequest model

label : Model -> String
label model =
    case model.key of
        "twitter-enabled" -> "Twitter"
        "instagram-enabled" -> "Instagram"
        "program-enabled" -> "Program"
        _ -> "Error"

icon : String -> Html msg
icon c =
    i [ class <| "setting__icon icon-" ++ c ] []

view : Model -> Html Msg
view model =
    li [ class "settings__setting" ]
       [ button [ classList [ ("settings__toggle", True), ("settings__toggle--enabled", model.value) ]
                , onClick Toggle
                ]
                [ icon <| if model.value then "check" else "close"
                , text <| label model
                ]
       ]
