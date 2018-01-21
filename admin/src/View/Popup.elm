module View.Popup exposing (..)

import Models.Popup as Model


view : Model -> Html Msg
view model =
    div [ classList [ ( "modal", True ), ( "modal--visible", True ) ] ]
        [ backdropView model ]


backdropView : Model -> Html Msg
backdropView model =
    div [ class "modal__backdrop", onClickStopPropagation ]
