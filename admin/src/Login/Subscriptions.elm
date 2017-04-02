module Login.Subscriptions exposing (subscriptions)

import Login.Model exposing (..)
import Login.Messages exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
