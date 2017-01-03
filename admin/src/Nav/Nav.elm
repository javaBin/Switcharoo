module Nav.Nav exposing (..)

import Navigation
import UrlParser exposing (Parser, (</>), oneOf, map, s, string, parseHash, top)
import Nav.Model exposing (Page(..))
import LocalStorage


toHash : Page -> String
toHash page =
    case page of
        LoggedOut ->
            "#"

        SlidesPage ->
            "#slides"

        SettingsPage ->
            "#settings"


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
            Maybe.withDefault SlidesPage <| parseHash pageParser location
        else
            LoggedOut


pageParser : Parser (Page -> a) a
pageParser =
    oneOf
        [ map LoggedOut (top)
        , map SlidesPage (s "slides")
        , map SettingsPage (s "settings")
        ]
