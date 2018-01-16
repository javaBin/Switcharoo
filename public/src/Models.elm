module Models exposing (Model, Data, Overlay, Slides, SlideWrapper(..), Flags)

import Models.Info as Info
import Models.Tweets as Tweets
import Models.Program as Program
import List.Zipper exposing (Zipper)


type alias Flags =
    { host : String
    }


type alias Model =
    { slides : Slides
    , overlay : Maybe Overlay
    }


type alias Data =
    { slides : List SlideWrapper
    , overlay : Maybe Overlay
    }


type alias Overlay =
    { image : String
    , style : List ( String, String )
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
