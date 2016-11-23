module Events exposing (onClickStopPropagation)

import Html exposing (Attribute)
import Html.Events exposing (Options, onWithOptions)
import Json.Decode exposing (succeed)


noBubble : Options
noBubble =
    { stopPropagation = True
    , preventDefault = False
    }


onClickStopPropagation : msg -> Attribute msg
onClickStopPropagation msg =
    onWithOptions "click" noBubble (succeed msg)
