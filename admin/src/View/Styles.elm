module View.Styles exposing (..)

import Html exposing (Html, div, text, h2, ul, li, span, input, button)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick, onInput)
import Models.Model exposing (Model, CssModel)
import Messages exposing (Msg(..), CssMsg(..))
import View.Box


viewStyles : Model -> Html Msg
viewStyles model =
    View.Box.box "Styles" <|
        div [ class "styles" ]
            [ ul [ class "styles-list" ] <|
                List.map viewStyle model.styles
            , button [ class "button style__save", onClick SaveStyles ] [ text "Save" ]
            ]


viewStyle : CssModel -> Html Msg
viewStyle model =
    li [ class "styles-list__style style" ]
        [ span [ class "style__label" ] [ text model.title ]
        , input [ class "style__input", type_ "color", value model.value, onInput (\s -> Css model <| Update s) ] []
        ]
