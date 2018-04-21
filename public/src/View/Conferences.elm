module View.Conferences exposing (view)

import Html exposing (Html, div, ul, li, text, a, h1, img)
import Html.Attributes exposing (class, href, src)
import Models exposing (Model)
import Messages exposing (Msg(..))
import Models.Conference
import Models.Page exposing (Page(..))
import Nav exposing (routeToString)


view : Model -> Html Msg
view model =
    div [ class "conferences" ]
        [ img [ class "conferences__logo", src "logo_dark.svg" ] []
        , h1 [ class "conferences__title" ] [ text "Conferences" ]
        , ul [ class "conferences__list" ] <| List.map viewConference model.conferences
        ]


viewConference : Models.Conference.Conference -> Html Msg
viewConference conference =
    li [ class "conferences__conference" ]
        [ a [ class "conferences__link", href <| routeToString <| Conference conference.id ] [ text conference.name ]
        ]
