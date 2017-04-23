module Models exposing (Model, Slides, SlideWrapper(..), Flags)

import Models.Info as Info
import Models.Tweets as Tweets
import Models.Program as Program
import List.Zipper exposing (Zipper)


type alias Flags =
    { host : String
    }


type alias Model =
    { slides : Slides
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
