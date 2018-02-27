module Nav.Nav exposing (..)

import Navigation
import UrlParser exposing (Parser, (</>), oneOf, map, s, string, parseHash, top, int)
import Nav.Model exposing (Page(..), ConferencePage(..))
import LocalStorage


routeToString : Page -> String
routeToString page =
    let
        parts =
            case page of
                LoggedOutPage ->
                    [ "" ]

                ConferencesPage ->
                    [ "conferences" ]

                ConferencePage conference page ->
                    [ "conferences", toString conference, conferencePageToString page ]
    in
        "#" ++ String.join "/" parts


conferencePageToString : ConferencePage -> String
conferencePageToString page =
    case page of
        SlidesPage ->
            "slides"

        SettingsPage ->
            "settings"

        StylesPage ->
            "styles"


hashParser : Navigation.Location -> Page
hashParser location =
    let
        loggedIn =
            case LocalStorage.get "login_token" of
                Just _ ->
                    True

                _ ->
                    False
    in
        if loggedIn then
            Maybe.withDefault ConferencesPage <| parseHash pageParser location
        else
            LoggedOutPage


pageParser : Parser (Page -> a) a
pageParser =
    oneOf
        [ map LoggedOutPage (top)
        , map ConferencesPage (s "conferences")
        , map ConferencePage (s "conferences" </> int </> conferencePageParser)
        ]


conferencePageParser : Parser (ConferencePage -> a) a
conferencePageParser =
    oneOf
        [ map SlidesPage (s "slides")
        , map SettingsPage (s "settings")
        , map StylesPage (s "styles")
        ]
