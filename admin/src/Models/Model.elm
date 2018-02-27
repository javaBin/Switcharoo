module Models.Model exposing (..)

import Models.ConferenceModel exposing (ConferenceModel)
import Models.Conference exposing (Conference)
import Auth
import Nav.Model exposing (Page(..))


type alias Flags =
    { loggedIn : Bool
    , host : String
    }


type alias Model =
    { selection : Maybe ConferenceModel
    , conferenceName : String
    , conferences : List Conference

    -- , slides : Models.Slides.Slides
    -- , services : Services.Model.Model
    -- , settings : List Setting
    , auth : Auth.AuthStatus
    , flags : Flags
    , page : Nav.Model.Page

    -- , styles : List CssModel
    -- , savedSuccessfully : Maybe Bool
    -- , connectedClients : Maybe String
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
