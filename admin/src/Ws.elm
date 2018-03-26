module Ws exposing (..)


type Command
    = Welcome
    | ClientCount String
    | Unknown String
    | Illegal String


type alias Message =
    ( Command, String )


parse : String -> Command
parse frame =
    case String.split ":" frame of
        cmd :: msg :: _ ->
            parseCommand cmd msg

        _ ->
            Illegal frame


parseCommand : String -> String -> Command
parseCommand cmd msg =
    case cmd of
        "WELCOME" ->
            Welcome

        "CLIENTCOUNT" ->
            ClientCount msg

        _ ->
            Unknown <| cmd ++ ":" ++ msg
