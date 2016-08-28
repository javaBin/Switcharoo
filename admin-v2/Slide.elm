-- module Slide exposing (Model, Msg, decoder, update, view, createOrEditSlide, editView, initModel, subscriptions)
module Slide exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, classList, style, type', id, value, draggable, placeholder, disabled, attribute, src)
import Html.Events exposing (onClick, onInput, on)
import Json.Decode.Extra exposing((|:))
import Json.Decode exposing (Decoder, succeed, string, bool, (:=))
import Http exposing (Request, Response, Body, defaultSettings, send, empty)
import Json.Encode as Encode exposing (Value, encode)
import Events exposing (onClickStopPropagation)
import Task
import Ports exposing (FileData, fileSelected, fileUploadSucceeded, fileUploadFailed)

type alias Model =
    { id : String
    , title : String
    , body : String
    , visible : Bool
    , index : String
    , type' : String
    }

initModel : Model
initModel = Model "" "" "" False "" ""

init : (Model, Cmd Msg)
init = (initModel, Cmd.none)

type Msg
    = ToggleVisibility
    | EditFailed Http.RawError
    | EditSucceeded Response
    | CreateFailed Http.RawError
    | CreateSucceeded Response
    | Delete
    | Edit
    | DeleteSucceeded Http.RawError
    | DeleteFailed Response
    | Title String
    | Body String
    | Index String
    | TextSlide
    | MediaSlide
    | FileSelected
    | FileUploaded FileData
    | FileUploadFailed String

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

        Delete ->
            (model, delete model)

        Edit ->
            (model, Cmd.none)

        DeleteSucceeded _ ->
            (model, Cmd.none)

        DeleteFailed _ ->
            (model, Cmd.none)

        Title newTitle ->
            ({model | title = newTitle}, Cmd.none)

        Body newBody ->
            ({model | body = newBody}, Cmd.none)

        Index newIndex ->
            ({model | index = newIndex}, Cmd.none)

        TextSlide ->
            ({model | type' = "text"}, Cmd.none)

        MediaSlide ->
            ({model | type' = "media"}, Cmd.none)

        FileSelected ->
            (model, fileSelected "MediaInputId")

        FileUploaded fileData ->
            ({model | title = fileData.location, body = fileData.location, type' = fileData.filetype}, Cmd.none)

        FileUploadFailed error ->
            (initModel, Cmd.none)

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

createOrEditSlide : Model -> Platform.Task Http.RawError Response
createOrEditSlide model =
    if model.id == "" then
        createSlide model
    else
        editSlide model

delete : Model -> Cmd Msg
delete model =
    Task.perform DeleteSucceeded DeleteFailed <|
    send defaultSettings
        { verb = "DELETE"
        , headers = []
        , url = "/slides/" ++ model.id
        , body = empty
        }

edit : Model -> Cmd Msg
edit model = Task.perform EditFailed EditSucceeded <| editSlide model

create : Model -> Cmd Msg
create model = Task.perform CreateFailed CreateSucceeded <| createSlide model

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch [fileUploadSucceeded FileUploaded, fileUploadFailed FileUploadFailed]

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
deleteButton model = button [ class "slide__delete", onClickStopPropagation Delete ] [ icon "trash" ]

editButton : Model -> Html Msg
editButton model = button [ class "slide__edit", onClickStopPropagation Edit ] [ icon "pencil" ]

viewText : Model -> Html Msg
viewText model =
    li [ class "slide"
       , onClick ToggleVisibility
       ]
       [ div [ classList [ ("slide__content", True)
                         , ("slide__content--visible", model.visible)
                         ]
             ]
             [ div [ class "slide__title" ] [ text model.title ]
             , div [ class "slide__body" ] [ text model.body ]
             ]
       , deleteButton model
       , editButton model
       ]

viewImage : Model -> Html Msg
viewImage model =
    li [ class "slide slide--image"
       , onClick ToggleVisibility
       ]
       [ div [ classList [ ("slide__content slide__content--image", True)
                         , ("slide__content--visible", model.visible)
                         ]
             , style [("background-image", "url(" ++ model.body ++ ")")]
             ]
             []
       , deleteButton model
       , editButton model
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
             [ video [ src model.body
                     , attribute "autoplay" "true"
                     , attribute "loop" "true"
                     , class "slide__video"
                     ]
                     []
             ]
       , deleteButton model
       , editButton model
       ]

editView : Model -> Html Msg
editView model =
    if model.type' == "text" then
        editTextView model
    else
        editMediaView model

editMediaView : Model -> Html Msg
editMediaView model =
    div []
        [ div [ class "tabs" ]
              [ button [ class "tabs__tab tabs__tab--active"
                       , disabled True
                       ]
                       [ text "Media" ]
              , button [ class "tabs__tab"
                       , onClickStopPropagation TextSlide
                       ]
                       [ text "Text"]
              ]
        , div [ class "modal__slide" ]
              [ input [ type' "text"
                      , class "input modal__index"
                      , onInput Index
                      , value model.index
                      , placeholder "Index"
                      ]
                      []
              , input [ type' "file"
                      , id "MediaInputId"
                      , on "change" (succeed FileSelected)
                      ]
                      []
              ]
        ]

editTextView : Model -> Html Msg
editTextView model =
    div []
        [ div [ class "tabs" ]
              [ button [ class "tabs__tab"
                       , onClickStopPropagation MediaSlide
                       ]
                       [ text "Media" ]
              , button [ class "tabs__tab tabs__tab--active"
                       , disabled True
                       ]
                       [ text "Text"]
              ]
        , div [ class "modal__slide" ]
              [ input [ type' "text"
                      , class "input modal__index"
                      , onInput Index
                      , value model.index
                      , placeholder "Index"
                      ]
                      []
              , input [ type' "text"
                      , class "input modal__title"
                      , onInput Title
                      , value model.title
                      , placeholder "Title"
                      ]
                      []
              , textarea [ onInput Body
                        , class "input modal__body"
                        , value model.body
                        , placeholder "Body"
                        ]
                        []
              ]
        ]
