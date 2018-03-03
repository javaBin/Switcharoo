module Models.Overlay exposing (..)


type alias Overlay =
    { enabled : Bool
    , image : String
    , placement : Placement
    , width : String
    , height : String
    }


type Placement
    = TopLeft
    | TopRight
    | BottomLeft
    | BottomRight


initOverlay : Overlay
initOverlay =
    Overlay
        False
        ""
        TopLeft
        ""
        ""
