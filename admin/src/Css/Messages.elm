module Css.Messages exposing (Msg(..))

import Http


type Msg
    = Update String
    | Save
    | Request (Result Http.Error String)
