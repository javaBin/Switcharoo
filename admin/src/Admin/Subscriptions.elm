module Admin.Subscriptions exposing (subscriptions)

import Admin.Model exposing (..)
import Admin.Messages exposing (..)
import Slides


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map SlideList <| Slides.subscriptions model.slides
