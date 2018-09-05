port module Auth exposing (..)


type alias UserData =
    { token : String
    }


type AuthStatus
    = LoggedOut
    | LoggedIn UserData


port login : () -> Cmd msg


port loginResult : (UserData -> msg) -> Sub msg
