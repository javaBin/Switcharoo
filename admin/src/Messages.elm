module Messages exposing (Msg(..), CssMsg(..))

import Auth
import Slides.Messages
import Settings.Messages
import Nav.Model exposing (Page)
import Http
import Model exposing (CssModel, SettingModel)


type Msg
    = Login
    | LoginResult Auth.UserData
    | SlidesMsg Slides.Messages.Msg
    | SettingsMsg Settings.Messages.Msg
    | PageChanged Page
    | GotStyles (Result Http.Error (List CssModel))
    | Css CssModel CssMsg
    | GetSettings (Result Http.Error (List SettingModel))
    | SettingChanged SettingModel String
    | SaveSettings
    | SettingsSaved (Result Http.Error (List SettingModel))


type CssMsg
    = Update String
    | Save
    | Request (Result Http.Error String)
