port module Auth exposing (..)

import User.Model


type alias UserData =
    { token : String
    , profile : User.Model.Model
    }


type AuthStatus
    = LoggedOut
    | LoggedIn UserData


port login : () -> Cmd msg


port loginResult : (UserData -> msg) -> Sub msg
