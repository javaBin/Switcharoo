module Messages exposing (Msg(..), ConferenceMsg(..), CssMsg(..))

import Auth
import Slides.Messages
import Slide.Messages
import Services.Messages
import Nav.Model exposing (Page, ConferencePage)
import Http
import Models.ConferenceModel exposing (CssModel, Setting)
import Models.Conference exposing (Conference)
import Models.Slides


type Msg
    = ConferenceMsg ConferenceMsg
    | LoginResult Auth.UserData
    | Login
    | PageChanged Page
    | Conferences (Result Http.Error (List Conference))
    | CreateConference
    | GetConferences
    | ConferenceName String


type ConferenceMsg
    = SlidesMsg Slides.Messages.Msg
    | SlideMsg Models.Slides.SlideModel Slide.Messages.Msg
    | GotStyles (Result Http.Error (List CssModel))
    | SaveStyles
    | SavedStyles (Result Http.Error (List CssModel))
    | Css CssModel CssMsg
    | GetSettings (Result Http.Error (List Setting))
    | SettingChanged Setting String
    | ServicesMsg Services.Messages.Msg
    | SaveSettings
    | SettingsSaved (Result Http.Error (List Setting))
    | DisableSavedSuccessfully
    | WSMessage String
    | SlidePopupCancel
    | SlidePopupSave Models.Slides.SlideModel
    | SlideSave (Result Http.Error Models.Slides.Slide)
    | Ignore


type CssMsg
    = Update String
    | Request (Result Http.Error String)
