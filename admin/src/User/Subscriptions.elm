module User.Subscriptions exposing (subscriptions)

import User.Model exposing (..)
import User.Messages exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
