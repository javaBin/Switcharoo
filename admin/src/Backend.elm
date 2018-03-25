module Backend exposing (..)

import Slides.Messages
import Slide.Model
import Slides.Messages
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
import Models.Overlay exposing (Overlay)
import Task


getOverlay : Conference -> Cmd ConferenceMsg
getOverlay conference =
    Http.send OverlaySaved <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/overlay"
            , body = Http.emptyBody
            , expect = Http.expectJson Decoder.overlayDecoder
            , timeout = Maybe.Nothing
            , withCredentials = False
            }


saveOverlay : Conference -> Overlay -> Cmd ConferenceMsg
saveOverlay conference overlay =
    Http.send OverlaySaved <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/overlay"
            , body = Http.jsonBody <| Encoder.overlayEncoder overlay
            , expect = Http.expectJson Decoder.overlayDecoder
            , timeout = Maybe.Nothing
            , withCredentials = False
            }


getConference : Int -> Cmd ConferenceMsg
getConference id =
    Http.send GotConference <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString id
            , body = Http.emptyBody
            , expect = Http.expectJson <| Decoder.conferenceDecoder
            , timeout = Maybe.Nothing
            , withCredentials = False
            }


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


getServices : Conference -> Cmd Services.Messages.Msg
getServices conference =
    Http.send Services.Messages.Settings <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/services"
            , body = Http.emptyBody
            , expect = Http.expectJson Decoder.servicesDecoder
            , timeout = Nothing
            , withCredentials = False
            }


toggleService : Conference -> Service.Model.Model -> Cmd Service.Messages.Msg
toggleService conference model =
    Http.send Service.Messages.Toggled <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/services/" ++ toString model.id
            , body = Http.emptyBody
            , expect = Http.expectString
            , timeout = Nothing
            , withCredentials = False
            }


getStyles : Conference -> Cmd ConferenceMsg
getStyles conference =
    Http.send GotStyles <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/css"
            , body = Http.emptyBody
            , expect = Http.expectJson Decoder.stylesDecoder
            , timeout = Nothing
            , withCredentials = False
            }


getSlides : Conference -> Cmd Slides.Messages.Msg
getSlides conference =
    Http.send Slides.Messages.SlidesResponse <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/slides"
            , body = Http.emptyBody
            , expect = Http.expectJson Decoders.Slide.decoder
            , timeout = Nothing
            , withCredentials = False
            }


updateIndexes : Conference -> List Int -> Cmd Slides.Messages.Msg
updateIndexes conference ids =
    Http.send Slides.Messages.IndexesUpdated <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/slides-indexes"
            , body = Http.jsonBody <| Encode.list <| List.map Encode.int ids
            , expect = Http.expectString
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


editSlide : Conference -> Models.Slides.Slide -> (Result.Result Http.Error Models.Slides.Slide -> msg) -> Cmd msg
editSlide conference model msg =
    Http.send msg <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/slides/" ++ toString model.id
            , body = Http.jsonBody <| encodeSlide model
            , expect = Http.expectJson Decoders.Slide.slideDecoder
            , timeout = Nothing
            , withCredentials = False
            }


createSlide : Conference -> Models.Slides.Slide -> (Result.Result Http.Error Models.Slides.Slide -> msg) -> Cmd msg
createSlide conference model msg =
    Http.send msg <|
        Http.request
            { method = "POST"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/slides"
            , body = Http.jsonBody <| encodeSlide model
            , expect = Http.expectJson Decoders.Slide.slideDecoder
            , timeout = Nothing
            , withCredentials = False
            }


deleteSlide : Conference -> Slide.Model.Slide -> Cmd Slides.Messages.Msg
deleteSlide conference model =
    Http.send Slides.Messages.DeleteResponse <|
        Http.request
            { method = "DELETE"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/slides/" ++ toString model.id
            , body = Http.emptyBody
            , expect = Http.expectString
            , timeout = Nothing
            , withCredentials = False
            }


editStyles : Conference -> List CssModel -> Cmd ConferenceMsg
editStyles conference styles =
    Http.send SavedStyles <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/css"
            , body = Http.jsonBody <| stylesEncoder styles
            , expect = Http.expectJson stylesDecoder
            , timeout = Nothing
            , withCredentials = False
            }


getSettings : Conference -> Cmd ConferenceMsg
getSettings conference =
    Http.send GetSettings <|
        Http.request
            { method = "GET"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/settings"
            , body = Http.emptyBody
            , expect = Http.expectJson settingsDecoder
            , timeout = Nothing
            , withCredentials = False
            }


saveSettings : Conference -> List Setting -> Cmd ConferenceMsg
saveSettings conference settings =
    Http.send SettingsSaved <|
        Http.request
            { method = "PUT"
            , headers = [ Http.header "authorization" <| authorization "login_token" ]
            , url = "/conferences/" ++ toString conference.id ++ "/settings"
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
