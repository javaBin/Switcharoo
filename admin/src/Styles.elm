module Styles exposing (..)

import Html exposing (Html, div, text, h2, ul, li, span, input, button)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick, onInput)
import Model exposing (Model, CssModel)
import Messages exposing (Msg(..), CssMsg(..))


viewStyles : Model -> Html Msg
viewStyles model =
    div [ class "styles" ]
        [ h2 [] [ text "Styles" ]
        , ul [ class "styles-list" ] <|
            List.map viewStyle model.styles
        ]


viewStyle : CssModel -> Html Msg
viewStyle model =
    li [ class "styles-list__style style" ]
        [ span [ class "style__label" ] [ text model.title ]
        , input [ class "style__input", type_ "color", value model.value, onInput (\s -> Css model <| Update s) ] []
        , button [ class "button style__save", onClick <| Css model Save ] [ text "Save" ]
        ]