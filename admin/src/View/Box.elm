module View.Box exposing (box, container)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)


container : List (Html msg) -> Html msg
container boxes =
    div [ class "box-container" ]
        boxes


box : String -> Html msg -> Html msg
box title body =
    div [ class "box" ]
        [ h1 [ class "box__title" ] [ text title ]
        , div [ class "box__content" ] [ body ]
        ]
