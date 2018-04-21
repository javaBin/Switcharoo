module Messages exposing (Msg(..))

import Http
import Models.Slides as Slides
import Models exposing (Data)
import Models.Conference
import Models.Page exposing (Page)


type Msg
    = Slides (Result Http.Error Data)
    | Refetch Int
    | RefetchSlides (Result Http.Error Data)
    | SlidesMsg Slides.Msg
    | WSMessage String
    | PageChanged Page
    | GotConferences (Result Http.Error (List Models.Conference.Conference))
