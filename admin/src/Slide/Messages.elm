module Slide.Messages exposing (Msg(..))

import Slide.Model exposing (..)
import Http
import Ports exposing (FileData)


type Msg
    = ToggleVisibility
    | ToggleResponse (Result Http.Error Model)
    | CreateResponse (Result Http.Error Model)
    | Delete
    | DeleteResponse (Result Http.Error String)
    | Edit
    | EditResponse (Result Http.Error Model)
    | Name String
    | Title String
    | Body String
    | Index String
    | TextSlide
    | MediaSlide
    | FileSelected
    | FileUploaded FileData
    | FileUploadFailed String
