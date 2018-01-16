module Messages exposing (Msg(..), CssMsg(..))

import Auth
import Slides.Messages
import Settings.Messages
import Nav.Model exposing (Page)
import Http
import Models.Model exposing (CssModel, Setting)


type Msg
    = Login
    | LoginResult Auth.UserData
    | SlidesMsg Slides.Messages.Msg
    | SettingsMsg Settings.Messages.Msg
    | PageChanged Page
    | GotStyles (Result Http.Error (List CssModel))
    | SaveStyles
    | SavedStyles (Result Http.Error (List CssModel))
    | Css CssModel CssMsg
    | GetSettings (Result Http.Error (List Setting))
    | SettingChanged Setting String
    | SaveSettings
    | SettingsSaved (Result Http.Error (List Setting))
    | DisableSavedSuccessfully
    | WSMessage String


type CssMsg
    = Update String
    | Request (Result Http.Error String)
