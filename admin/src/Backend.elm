module Backend exposing (..)

import Slides.Messages
import Slide.Model
import Slide.Messages
import Services.Messages
import Service.Messages
import Service.Model
import LocalStorage
import Http
import Json.Decode as Decode exposing (Decoder, nullable)
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Models.ConferenceModel exposing (CssModel, Setting)
import Models.Conference exposing (Conference)
import Messages exposing (Msg(..), ConferenceMsg(..), CssMsg(..))
import Decoder exposing (settingsDecoder, stylesDecoder, conferenceDecoder)
import Encoder exposing (settingsEncoder, stylesEncoder)
import Decoders.Slide
import Models.Slides
import Task


getConferences : String -> Cmd Msg
getConferences hack =
    Task.attempt Conferences <| getConferencesTask hack


getConferencesTask : String -> Task.Task Http.Error (List Conference)
getConferencesTask hack =
    Http.toTask <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences"
            , body = Http.emptyBody
            , expect = Http.expectJson Decoder.conferencesDecoder
            , timeout = Nothing
            , withCredentials = False
            }


createConference : Conference -> Task.Task Http.Error Conference
createConference conference =
    Http.toTask <|
        Http.request
            { method = "POST"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences"
            , body = Http.jsonBody <| Encoder.conferenceEncoder conference
            , expect = Http.expectJson Decoder.conferenceDecoder
            , timeout = Maybe.Nothing
            , withCredentials = False
            }


getServices : Decoder (List Service.Model.Model) -> Cmd Services.Messages.Msg
getServices decoder =
    Http.send Services.Messages.Settings <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/services"
            , body = Http.emptyBody
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


toggleService : Service.Model.Model -> Cmd Service.Messages.Msg
toggleService model =
    Http.send Service.Messages.Toggled <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/services/" ++ toString model.id
            , body = Http.emptyBody
            , expect = Http.expectString
            , timeout = Nothing
            , withCredentials = False
            }


getStyles : Decoder (List CssModel) -> Cmd ConferenceMsg
getStyles decoder =
    Http.send GotStyles <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/css"
            , body = Http.emptyBody
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


getSlides : Decoder (List Models.Slides.Slide) -> Cmd Slides.Messages.Msg
getSlides decoder =
    Http.send Slides.Messages.SlidesResponse <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/slides"
            , body = Http.emptyBody
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


encodeSlide : Slide.Model.Slide -> Encode.Value
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
            , ( "color", Maybe.map Encode.string model.color |> Maybe.withDefault Encode.null )
            ]


editSlide : Models.Slides.Slide -> (Result.Result Http.Error Models.Slides.Slide -> msg) -> Cmd msg
editSlide model msg =
    Http.send msg <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/slides/" ++ toString model.id
            , body = Http.jsonBody <| encodeSlide model
            , expect = Http.expectJson Decoders.Slide.slideDecoder
            , timeout = Nothing
            , withCredentials = False
            }


createSlide : Models.Slides.Slide -> (Result.Result Http.Error Models.Slides.Slide -> msg) -> Cmd msg
createSlide model msg =
    Http.send msg <|
        Http.request
            { method = "POST"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/slides"
            , body = Http.jsonBody <| encodeSlide model
            , expect = Http.expectJson Decoders.Slide.slideDecoder
            , timeout = Nothing
            , withCredentials = False
            }


deleteSlide : Slide.Model.Slide -> Cmd Slide.Messages.Msg
deleteSlide model =
    Http.send Slide.Messages.DeleteResponse <|
        Http.request
            { method = "DELETE"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/slides/" ++ toString model.id
            , body = Http.emptyBody
            , expect = Http.expectString
            , timeout = Nothing
            , withCredentials = False
            }


editStyles : List CssModel -> Cmd ConferenceMsg
editStyles styles =
    Http.send SavedStyles <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/css"
            , body = Http.jsonBody <| stylesEncoder styles
            , expect = Http.expectJson stylesDecoder
            , timeout = Nothing
            , withCredentials = False
            }


getSettings : String -> Cmd ConferenceMsg
getSettings _ =
    Http.send GetSettings <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/settings"
            , body = Http.emptyBody
            , expect = Http.expectJson settingsDecoder
            , timeout = Nothing
            , withCredentials = False
            }


saveSettings : List Setting -> Cmd ConferenceMsg
saveSettings settings =
    Http.send SettingsSaved <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/settings"
            , body = Http.jsonBody <| settingsEncoder settings
            , expect = Http.expectJson settingsDecoder
            , timeout = Nothing
            , withCredentials = False
            }


authorization : String -> String
authorization loginToken =
    case LocalStorage.get loginToken of
        Just token ->
            "Bearer " ++ token

        Nothing ->
            ""
