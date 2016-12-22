module Admin.Messages exposing (Msg(..))

import Slides
import Settings


type Msg
    = SlideList Slides.Msg
    | SettingsMsg Settings.Msg
