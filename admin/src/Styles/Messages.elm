module Styles.Messages exposing (Msg(..))

import Css.Messages
import Css.Model
import Http


type Msg
    = CssMsg Css.Model.Model Css.Messages.Msg
    | GotStyles (Result Http.Error (List Css.Model.Model))
