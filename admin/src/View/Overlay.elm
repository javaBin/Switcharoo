module View.Overlay exposing (view)

import Html exposing (Html, div, input, text, label, select, option, img, button)
import Html.Attributes exposing (class, type_, id, for, value, src, selected, checked)
import Html.Events exposing (on, targetValue, onCheck, onInput, onClick)
import Messages exposing (ConferenceMsg(..))
import Models.Overlay exposing (Overlay, Placement(..))
import Json.Decode exposing (Decoder, andThen, succeed)
import View.Box


view : Overlay -> Html ConferenceMsg
view overlay =
    View.Box.box "Overlay" <|
        div [ class "overlay" ]
            [ div [ class "overlay__enable" ]
                [ input [ type_ "checkbox", id "overlay-enable", onCheck OverlayEnable, checked overlay.enabled ] []
                , label [ for "overlay-enable" ] [ text "Enable" ]
                ]
            , div [ class "overlay__upload" ]
                [ input [ type_ "file", id "overlay-file", on "change" (succeed OverlayFileSelected) ] []
                ]
            , div [ class "overlay__placement" ]
                [ select
                    [ id "overlay-placement"
                    , on "change" (Json.Decode.map OverlayPlacement decodePlacement)
                    ]
                  <|
                    List.map (placement overlay.placement) locations
                ]
            , div [ class "overlay__width" ]
                [ label [ for "overlay-width", onInput OverlayWidth ] [ text "Width" ]
                , input [ type_ "text", id "overlay-width", value overlay.width, class "input--box" ] []
                ]
            , div [ class "overlay__height" ]
                [ label [ for "overlay-height", onInput OverlayHeight ] [ text "Height" ]
                , input [ type_ "text", id "overlay-height", value overlay.height, class "input--box" ] []
                ]
            , img [ class "overlay__image", src overlay.image ] []
            , button [ class "button", onClick OverlaySave ] [ text "Save" ]
            ]


placement : Placement -> Placement -> Html ConferenceMsg
placement selectedPlacement placement =
    option [ value <| toString placement, selected <| placement == selectedPlacement ]
        [ text <| toString placement ]


locations : List Placement
locations =
    [ TopLeft, TopRight, BottomLeft, BottomRight ]


decodePlacement : Json.Decode.Decoder Placement
decodePlacement =
    andThen stringToPlacement targetValue


stringToPlacement : String -> Decoder Placement
stringToPlacement val =
    case val of
        "TopLeft" ->
            succeed TopLeft

        "TopRight" ->
            succeed TopRight

        "BottomLeft" ->
            succeed BottomLeft

        "BottomRight" ->
            succeed BottomRight

        _ ->
            Json.Decode.fail <| "Invalid role " ++ val
