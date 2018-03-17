module Slides.Messages exposing (Msg(..))

import Http
import Slide.Model exposing (..)
import Models.Slides
import Ports exposing (FileData)
import Models.Slides exposing (SlideModel)


type Msg
    = GetSlides
    | SlidesResponse (Result Http.Error (List Models.Slides.Slide))
    | NewSlide
    | ToggleVisibility SlideModel
    | ToggleResponse (Result Http.Error Slide)
    | CreateResponse (Result Http.Error Slide)
    | ToggleDelete SlideModel
    | Delete SlideModel
    | DeleteResponse (Result Http.Error String)
    | Edit SlideModel
    | Name SlideModel String
    | Title SlideModel String
    | Body SlideModel String
    | Index SlideModel String
    | TextSlide SlideModel
    | MediaSlide SlideModel
    | Color SlideModel (Maybe String)
    | FileSelected SlideModel
    | FileUploaded SlideModel FileData
    | FileUploadFailed SlideModel String
    | Move SlideModel
    | CancelMove
    | Drop Int
    | IndexesUpdated (Result Http.Error String)
