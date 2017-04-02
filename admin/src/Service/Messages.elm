module Service.Messages exposing (Msg(..))

import Http


type Msg
    = Toggle
    | Toggled (Result Http.Error String)
