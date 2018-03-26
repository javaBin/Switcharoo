module Messages exposing (Msg(..))

import Http
import Models.Slides as Slides
import Models exposing (Data)


type Msg
    = Slides (Result Http.Error Data)
    | Refetch
    | RefetchSlides (Result Http.Error Data)
    | SlidesMsg Slides.Msg
    | WSMessage String
