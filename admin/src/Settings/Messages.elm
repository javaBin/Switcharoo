module Settings.Messages exposing (Msg(..))

import Services.Messages


type Msg
    = ServicesMsg Services.Messages.Msg
