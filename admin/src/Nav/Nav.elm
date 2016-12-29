module Nav.Nav exposing (..)

import Navigation
import UrlParser exposing (Parser, (</>), oneOf, map, s, string, parseHash, top)
import Nav.Model exposing (Page(..))


toHash : Page -> String
toHash page =
    case page of
        SlidesPage ->
            "#slides"

        SettingsPage ->
            "#settings"


hashParser : Navigation.Location -> Page
hashParser location =
    Maybe.withDefault SlidesPage <| parseHash pageParser location


pageParser : Parser (Page -> a) a
pageParser =
    oneOf
        [ map SlidesPage (s "slides")
        , map SettingsPage (s "settings")
        ]
