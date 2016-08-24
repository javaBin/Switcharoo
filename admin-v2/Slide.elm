module Slide exposing (Model, Msg, decoder, update, view, createSlide)

import Html exposing (..)
import Html.Attributes exposing (class, classList, style)
import Html.Events exposing (onClick)
import Json.Decode.Extra exposing((|:))
import Json.Decode exposing (Decoder, succeed, string, bool, (:=))
import Http exposing (Request, Response, Body, defaultSettings, send)
import Json.Encode as Encode exposing (Value, encode)
import Task

type alias Model =
    { id : String
    , title : String
    , body : String
    , visible : Bool
    , index : String
    , type' : String
    }

init : (Model, Cmd Msg)
init = (Model "" "" "" False "" "", Cmd.none)

type Msg
    = ToggleVisibility
    | EditFailed Http.RawError
    | EditSucceeded Response
    | CreateFailed Http.RawError
    | CreateSucceeded Response

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ToggleVisibility ->
            let
                newModel = {model | visible = not model.visible}
            in
                (newModel, edit newModel)

        EditFailed _ ->
            (model, Cmd.none)

        EditSucceeded _ ->
            (model, Cmd.none)

        CreateFailed _ ->
            (model, Cmd.none)

        CreateSucceeded _ ->
             (model, Cmd.none)

decoder : Decoder Model
decoder =
    succeed Model
        |: ("_id" := string)
        |: ("title" := string)
        |: ("body" := string)
        |: ("visible" := bool)
        |: ("index" := string)
        |: ("type" := string)

encodeSlide : Model -> Value
encodeSlide model =
    Encode.object <|
        ( if model.id == "" then
            []
        else
            [("_id", Encode.string model.id)] )
        `List.append`
        [ ("title", Encode.string model.title)
        , ("body", Encode.string model.body)
        , ("visible", Encode.bool model.visible)
        , ("index", Encode.string model.index)
        , ("type", Encode.string model.type')
        ]

editSlide : Model -> Platform.Task Http.RawError Response
editSlide model =
    send defaultSettings
        { verb = "PUT"
        , headers = [("Content-Type", "application/json")]
        , url = "/slides/" ++ model.id
        , body = Http.string <| encode 0 <| encodeSlide model
        }

createSlide : Model -> Platform.Task Http.RawError Response
createSlide model =
    send defaultSettings
        { verb = "POST"
        , headers = [("Content-Type", "application/json")]
        , url = "/slides"
        , body = Http.string <| encode 0 <| encodeSlide model
        }

edit : Model -> Cmd Msg
edit model = Task.perform EditFailed EditSucceeded <| editSlide model

create : Model -> Cmd Msg
create model = Task.perform CreateFailed CreateSucceeded <| createSlide model

icon : String -> Html msg
icon c =
    i [ class <| "icon-" ++ c ] []

view : Model -> Html Msg
view model =
    case model.type' of
        "text" -> viewText model
        "image" -> viewImage model
        _      -> viewVideo model

deleteButton : Model -> Html Msg
deleteButton model = button [ class "slide__delete" ] [ icon "trash" ]

viewText : Model -> Html Msg
viewText model =
    li [ class "slide", onClick ToggleVisibility ]
       [ div [ classList [("slide__content", True), ("slide__content--visible", model.visible)] ]
             [ div [ class "slide__title" ] [ text model.title ]
             , div [ class "slide__body" ] [ text model.body ]
             ]
       , deleteButton model
       ]

viewImage : Model -> Html Msg
viewImage model =
    li [ class "slide slide--image", onClick ToggleVisibility ]
       [ div [ classList [("slide__content slide__content--image", True), ("slide__content--visible", model.visible)]
             , style [("background-image", "url(" ++ model.body ++ ")")]
             ]
             []
       , deleteButton model
       ]

viewVideo : Model -> Html Msg
viewVideo model =
    li [ class "slide slide--video"
       , onClick ToggleVisibility
       ]
       [ div [ classList [("slide__content slide__content--video", True)
                         , ("slide__content--visible", model.visible)
                         ]
             ]
             [ text "video" ]
       , deleteButton model
       ]
