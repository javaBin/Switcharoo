module Admin.Messages exposing (Msg(..))

import Slides.Messages
import Services.Messages
import Nav.Model


type Msg
    = SlideList Slides.Messages.Msg
    | SettingsMsg Services.Messages.Msg
    | UrlUpdate Nav.Model.Page
