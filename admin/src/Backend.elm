module Backend exposing (..)

import Slides.Messages
import Slide.Model
import Services.Messages
import Service
import LocalStorage
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Json.Decode.Extra exposing ((|:))


getSettings : Decoder (List Service.Model) -> Cmd Services.Messages.Msg
getSettings decoder =
    Http.send Services.Messages.Settings <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" authorization ]
            , url = "/settings"
            , body = Http.emptyBody
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


getSlides : Decoder (List Slide.Model.Model) -> Cmd Slides.Messages.Msg
getSlides decoder =
    Http.send Slides.Messages.SlidesResponse <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" authorization ]
            , url = "/slides"
            , body = Http.emptyBody
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


encodeSlide : Slide.Model.Model -> Encode.Value
encodeSlide model =
    Encode.object <|
        List.append
            (if model.id == -1 then
                []
             else
                [ ( "id", Encode.int model.id ) ]
            )
            [ ( "name", Encode.string model.name )
            , ( "title", Encode.string model.title )
            , ( "body", Encode.string model.body )
            , ( "visible", Encode.bool model.visible )
            , ( "index", Encode.int model.index )
            , ( "type", Encode.string model.type_ )
            ]


editSlide : Slide.Model.Model -> (Result.Result Http.Error Slide.Model.Model -> msg) -> Cmd msg
editSlide model msg =
    Http.send msg <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "authorization" authorization ]
            , url = "/slides/" ++ toString model.id
            , body = Http.jsonBody <| encodeSlide model
            , expect = Http.expectJson slideDecoder
            , timeout = Nothing
            , withCredentials = False
            }


createSlide : Slide.Model.Model -> (Result.Result Http.Error Slide.Model.Model -> msg) -> Cmd msg
createSlide model msg =
    Http.send msg <|
        Http.request
            { method = "POST"
            , headers = [ Http.header "authorization" authorization ]
            , url = "/slides"
            , body = Http.jsonBody <| encodeSlide model
            , expect = Http.expectJson slideDecoder
            , timeout = Nothing
            , withCredentials = False
            }


slideDecoder : Decoder Slide.Model.Model
slideDecoder =
    Decode.succeed Slide.Model.Model
        |: Decode.field "id" Decode.int
        |: Decode.field "name" Decode.string
        |: Decode.field "title" Decode.string
        |: Decode.field "body" Decode.string
        |: Decode.field "visible" Decode.bool
        |: Decode.field "index" Decode.int
        |: Decode.field "type" Decode.string


authorization : String
authorization =
    case LocalStorage.get "login_token" of
        Just token ->
            "Bearer " ++ token

        Nothing ->
            ""
