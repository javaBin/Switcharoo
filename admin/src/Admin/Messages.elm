module Admin.Messages exposing (Msg(..))

import Slides.Messages
import Settings.Messages
import Nav.Model


type Msg
    = SlideList Slides.Messages.Msg
    | SettingsMsg Settings.Messages.Msg
    | UrlUpdate Nav.Model.Page
