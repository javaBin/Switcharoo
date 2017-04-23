port module SocketIO exposing (..)


port connect : String -> Cmd msg


port onMessage : (String -> msg) -> Sub msg
