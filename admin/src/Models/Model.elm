module Models.Model exposing (..)

import Settings.Model
import Models.Slides
import Auth
import Nav.Model exposing (Page(..))


type alias Flags =
    { loggedIn : Bool
    , host : String
    }


type alias Model =
    { slides : Models.Slides.Slides
    , services : Settings.Model.Model
    , settings : List Setting
    , auth : Auth.AuthStatus
    , flags : Flags
    , page : Nav.Model.Page
    , styles : List CssModel
    , savedSuccessfully : Maybe Bool
    , connectedClients : Maybe String
    }


type alias CssModel =
    { id : Int
    , selector : String
    , property : String
    , value : String
    , type_ : String
    , title : String
    }


type alias Setting =
    { id : Int
    , key : String
    , hint : String
    , value : String
    }


initModel : Flags -> Page -> Model
initModel flags page =
    Model
        Models.Slides.initSlides
        Settings.Model.initModel
        []
        Auth.LoggedOut
        flags
        page
        []
        Nothing
        Nothing
