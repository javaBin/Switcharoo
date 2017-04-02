module Styles.Decoder exposing (decoder)

import Css.Model
import Css.Decoder
import Json.Decode exposing (Decoder, list)


decoder : Decoder (List Css.Model.Model)
decoder =
    list Css.Decoder.decoder
