module Models exposing (Model, Data, Overlay, Slides, SlideWrapper(..), Flags, Settings)

import Models.Info as Info
import Models.Tweets as Tweets
import Models.Program as Program
import List.Zipper exposing (Zipper)
import Models.Page exposing (Page)
import Models.Conference


type alias Flags =
    { host : String
    , secure : Bool
    }


type alias Settings =
    { host : String
    , secure : Bool
    }


type alias Model =
    { slides : Slides
    , overlay : Maybe Overlay
    , settings : Settings
    , conferences : List Models.Conference.Conference
    , page : Page
    }


type alias Data =
    { slides : List SlideWrapper
    , overlay : Maybe Overlay
    }


type alias Overlay =
    { enabled : Bool
    , image : String
    , placement : String
    , width : String
    , height : String
    }


type alias Slides =
    { switching : Bool
    , nextSlides : Maybe (Zipper SlideWrapper)
    , slides : Zipper SlideWrapper
    }


type SlideWrapper
    = InfoWrapper Info.Model
    | TweetsWrapper Tweets.Model
    | ProgramWrapper Program.Model
