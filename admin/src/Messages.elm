module Messages exposing (Msg(..), CssMsg(..))

import Auth
import Slides.Messages
import Settings.Messages
import Nav.Model exposing (Page)
import Http
import Model exposing (CssModel)


type Msg
    = Login
    | LoginResult Auth.UserData
    | SlidesMsg Slides.Messages.Msg
    | SettingsMsg Settings.Messages.Msg
    | PageChanged Page
    | GotStyles (Result Http.Error (List CssModel))
    | Css CssModel CssMsg


type CssMsg
    = Update String
    | Save
    | Request (Result Http.Error String)
