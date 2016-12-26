module Settings.Messages exposing (Msg(..))

import Setting
import Http


type Msg
    = SettingMsg Setting.Model Setting.Msg
    | Settings (Result Http.Error (List Setting.Model))
