module Messages exposing (Msg(..), CssMsg(..))

import Auth
import Slides.Messages
import Slide.Messages
import Services.Messages
import Nav.Model exposing (Page)
import Http
import Models.Model exposing (CssModel, Setting)
import Models.Slides


type Msg
    = Login
    | LoginResult Auth.UserData
    | SlidesMsg Slides.Messages.Msg
    | SlideMsg Models.Slides.SlideModel Slide.Messages.Msg
    | PageChanged Page
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
