module Messages exposing (Msg(..), CssMsg(..))

import Auth
import Slides.Messages
import Settings.Messages
import Nav.Model exposing (Page)
import Http
import Css.Model


type Msg
    = Login
    | LoginResult Auth.UserData
    | SlidesMsg Slides.Messages.Msg
    | SettingsMsg Settings.Messages.Msg
    | PageChanged Page
    | GotStyles (Result Http.Error (List Css.Model.Model))
    | Css CssMsg


type CssMsg
    = Update String
    | Save
    | Request (Result Http.Error String)
