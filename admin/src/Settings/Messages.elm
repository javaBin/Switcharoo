module Settings.Messages exposing (Msg(..))

import Services.Messages
import Styles.Messages


type Msg
    = ServicesMsg Services.Messages.Msg
    | StylesMsg Styles.Messages.Msg
