module View.Box exposing (box, container)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)


container : List (Html msg) -> Html msg
container boxes =
    div [ class "box-container" ]
        boxes


box : String -> List (Html msg) -> Html msg -> Html msg
box title actions body =
    div [ class "box" ]
        [ div [ class "box__header" ]
            ([ h1 [ class "box__title" ] [ text title ]
             ]
                ++ actions
            )
        , div [ class "box__content" ] [ body ]
        ]
