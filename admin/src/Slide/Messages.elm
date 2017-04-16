module Slide.Messages exposing (Msg(..))

import Slide.Model exposing (..)
import Http
import Ports exposing (FileData)


type Msg
    = ToggleVisibility
    | ToggleResponse (Result Http.Error Slide)
    | CreateResponse (Result Http.Error Slide)
    | ToggleDelete
    | Delete
    | DeleteResponse (Result Http.Error String)
    | Edit
    | EditResponse (Result Http.Error Slide)
    | Name String
    | Title String
    | Body String
    | Index String
    | TextSlide
    | MediaSlide
    | Color (Maybe String)
    | FileSelected
    | FileUploaded FileData
    | FileUploadFailed String
