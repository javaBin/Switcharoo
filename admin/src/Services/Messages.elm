module Services.Messages exposing (Msg(..))

import Service
import Http


type Msg
    = SettingMsg Service.Model Service.Msg
    | Settings (Result Http.Error (List Service.Model))
