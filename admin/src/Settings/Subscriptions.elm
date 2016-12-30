module Settings.Subscriptions exposing (subscriptions)

import Settings.Model exposing (..)
import Settings.Messages exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
