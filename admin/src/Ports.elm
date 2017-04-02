port module Ports exposing (..)


type alias MediaPortData =
    { contents : String
    , filename : String
    }


type alias FileData =
    { location : String
    , filetype : String
    }


port fileSelected : String -> Cmd msg


port fileUploadSucceeded : (FileData -> msg) -> Sub msg


port fileUploadFailed : (String -> msg) -> Sub msg
