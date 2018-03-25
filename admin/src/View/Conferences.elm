module View.Conferences exposing (view)

import Html exposing (Html, div, input, button, text, ul, li, a, i)
import Html.Attributes exposing (class, type_, placeholder, href)
import Html.Events exposing (onClick, onInput)
import Models.Model exposing (Model)
import Models.Conference exposing (Conference)
import Messages exposing (Msg(..))
import Nav.Model exposing (Page(..), ConferencePage(..))
import Nav.Nav exposing (routeToString)
import View.Box
import Icons


view : Model -> Html Msg
view model =
    div [ class "conferences" ]
        [ View.Box.box "New conference" [] <| viewCreateConference model
        , viewConferences model
        ]


viewConferences : Model -> Html Msg
viewConferences model =
    ul [ class "conferences__list" ] <|
        List.map
            viewConference
            model.conferences


viewConference : Conference -> Html Msg
viewConference conference =
    li [ class "conferences__conference" ]
        [ a
            [ class "conferences__conference-link"
            , href <| routeToString <| ConferencePage conference.id SlidesPage
            ]
            [ text conference.name
            , Icons.keyboardArrowRight
            ]
        ]


viewCreateConference : Model -> Html Msg
viewCreateConference model =
    div [ class "conferences__new" ]
        [ input [ type_ "text", class "input conferences__input", placeholder "Name", onInput ConferenceName ] []
        , button [ class "conferences__create button", onClick CreateConference ] [ text "Create conference" ]
        ]
