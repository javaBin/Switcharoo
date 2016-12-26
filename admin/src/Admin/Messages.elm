module Admin.Messages exposing (Msg(..))

import Slides.Messages
import Settings.Messages


type Msg
    = SlideList Slides.Messages.Msg
    | SettingsMsg Settings.Messages.Msg
