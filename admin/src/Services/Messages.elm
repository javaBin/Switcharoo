module Services.Messages exposing (Msg(..))

import Service.Messages
import Service.Model
import Http


type Msg
    = SettingMsg Service.Model.Model Service.Messages.Msg
    | Settings (Result Http.Error (List Service.Model.Model))
