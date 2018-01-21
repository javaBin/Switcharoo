module Popup exposing (config)

import Html exposing (Html, div, button, text, i)
import Html.Attributes exposing (class, classList, attribute)
import Events exposing (onClickStopPropagation)


type alias Config msg =
    { saveMsg : msg
    , cancelMsg : msg
    , header : String
    , body : Html msg
    }


config : msg -> msg -> String -> Html msg -> Config msg
config saveMsg cancelMsg header body =
    { saveMsg = saveMsg
    , cancelMsg = cancelMsg
    , header = header
    , body = body
    }


view : Config msg -> Html msg
view config =
    div [ classList [ ( "modal", True ), ( "modal--visible", True ) ] ]
        [ backdropView config ]


backdropView : Config msg -> Html msg
backdropView config =
    div [ class "modal__backdrop", onClickStopPropagation config.cancelMsg ]
        [ modalView config ]


modalView : Config msg -> Html msg
modalView config =
    div [ class "modal__wrapper", onClickStopPropagation config.cancelMsg ]
        [ div [ class "modal__header" ]
            [ text config.header ]
        , modalContentView config.body
        , modalFooterView config
        ]


modalContentView : Html msg -> Html msg
modalContentView body =
    div [ class "modal__content" ]
        [ body ]


modalFooterView : Config msg -> Html msg
modalFooterView config =
    div [ class "modal__footer" ]
        [ button
            [ class "button button--cancel"
            , onClickStopPropagation config.cancelMsg
            ]
            [ icon "close" ]
        , button
            [ class "button button--ok modal__save"
            , onClickStopPropagation config.saveMsg
            ]
            [ icon "check" ]
        ]


icon : String -> Html msg
icon c =
    i [ class <| "icon-" ++ c ] []
