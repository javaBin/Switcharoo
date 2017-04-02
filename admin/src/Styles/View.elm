module Styles.View exposing (view)

import Styles.Model exposing (..)
import Styles.Messages exposing (..)
import Css.Model
import Css.View
import Html exposing (Html, div, text, h2, ul)
import Html.Attributes exposing (class)


view : Model -> Html Msg
view model =
    div [ class "styles" ]
        [ h2 [] [ text "Styles" ]
        , ul [ class "styles-list" ] <|
            List.map viewStyle model.styles
        ]


viewStyle : Css.Model.Model -> Html Msg
viewStyle style =
    Html.map (CssMsg style) <| Css.View.view style
