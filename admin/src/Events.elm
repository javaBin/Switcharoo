module Events exposing (onClickStopPropagation, onDragStart, onDragEnd, onDrop)

import Html exposing (Attribute)
import Html.Events exposing (Options, onWithOptions, on)
import Json.Decode exposing (succeed)


noBubble : Options
noBubble =
    { stopPropagation = True
    , preventDefault = False
    }


onClickStopPropagation : msg -> Attribute msg
onClickStopPropagation msg =
    onWithOptions "click" noBubble (succeed msg)


onDragStart : msg -> Attribute msg
onDragStart msg =
    on "dragstart" <| Json.Decode.succeed msg


onDragEnd : msg -> Attribute msg
onDragEnd msg =
    on "dragend" <| Json.Decode.succeed msg


onDrop : msg -> Attribute msg
onDrop msg =
    onPreventHelper "drop" msg


onPreventHelper : String -> msg -> Attribute msg
onPreventHelper event msg =
    onWithOptions
        event
        { preventDefault = True
        , stopPropagation = False
        }
        (Json.Decode.succeed msg)
