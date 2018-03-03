module Models.ConferenceModel exposing (..)

import Services.Model
import Models.Slides
import Models.Conference exposing (Conference)
import Models.Overlay exposing (Overlay, initOverlay)
import Nav.Model exposing (ConferencePage(..))


type alias ConferenceModel =
    { conference : Conference
    , page : ConferencePage
    , savedSuccessfully : Maybe Bool
    , slides : Models.Slides.Slides
    , services : Services.Model.Model
    , settings : List Setting
    , styles : List CssModel
    , connectedClients : Maybe String
    , overlay : Overlay
    }


type alias Setting =
    { id : Int
    , key : String
    , hint : String
    , value : String
    }


type alias CssModel =
    { id : Int
    , selector : String
    , property : String
    , value : String
    , type_ : String
    , title : String
    }


initConferenceModel : ConferencePage -> Conference -> ConferenceModel
initConferenceModel page conference =
    ConferenceModel
        conference
        page
        Nothing
        Models.Slides.initSlides
        Services.Model.init
        []
        []
        Nothing
        initOverlay
