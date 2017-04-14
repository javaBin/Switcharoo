module Model exposing (..)

import Slides.Model
import Settings.Model
import Auth
import Nav.Model exposing (Page(..))


type alias Flags =
    { loggedIn : Bool
    }


type alias Model =
    { slides : Slides.Model.Model
    , settings : Settings.Model.Model
    , auth : Auth.AuthStatus
    , flags : Flags
    , page : Nav.Model.Page
    , styles : List CssModel
    }



-- type alias StylesModel =
--     { styles : List CssModel
--     }


type alias CssModel =
    { id : Int
    , selector : String
    , property : String
    , value : String
    , type_ : String
    , title : String
    }


initModel : Flags -> Page -> Model
initModel flags page =
    Model Slides.Model.init
        Settings.Model.initModel
        Auth.LoggedOut
        flags
        page
        []
