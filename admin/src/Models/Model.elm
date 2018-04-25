module Models.Model exposing (..)

import Models.ConferenceModel exposing (ConferenceModel)
import Models.Conference exposing (Conference)
import Auth
import Nav.Model exposing (Page(..))


type alias Flags =
    { loggedIn : Bool
    , host : String
    , secure : Bool
    }


type alias Model =
    { selection : Maybe ConferenceModel
    , conferenceName : String
    , conferences : List Conference
    , auth : Auth.AuthStatus
    , flags : Flags
    , page : Nav.Model.Page
    }


initModel : Flags -> Page -> Model
initModel flags page =
    Model
        Nothing
        ""
        []
        Auth.LoggedOut
        flags
        page
