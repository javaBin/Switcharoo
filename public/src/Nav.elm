module Nav exposing (..)

import Navigation
import UrlParser exposing (Parser, (</>), oneOf, map, parseHash, top, int)
import Models.Page exposing (Page(..))


routeToString : Page -> String
routeToString page =
    case page of
        Conferences ->
            "#"

        Conference conference ->
            "#" ++ toString conference


hashParser : Navigation.Location -> Page
hashParser location =
    Maybe.withDefault Conferences <| parseHash pageParser location


pageParser : Parser (Page -> a) a
pageParser =
    oneOf
        [ map Conferences (top)
        , map Conference (int)
        ]
