module Decoder.Slides exposing (decoder)

import Json.Decode exposing (Decoder, andThen, succeed, list, string, fail, field)
import Models exposing (SlideWrapper(..))
import Models.Info as Info
import Models.Tweets as Tweets
import Models.Program as Program


decoder : Decoder (List SlideWrapper)
decoder =
    list <| andThen slideWrapper <| field "type" string


slideWrapper : String -> Decoder SlideWrapper
slideWrapper t =
    case t of
        "text" ->
            Info.info |> andThen (succeed << InfoWrapper)

        "image" ->
            Info.info |> andThen (succeed << InfoWrapper)

        "video" ->
            Info.info |> andThen (succeed << InfoWrapper)

        "tweets" ->
            Tweets.tweets |> andThen (succeed << TweetsWrapper)

        "program" ->
            Program.decoder |> andThen (succeed << ProgramWrapper)

        unknown ->
            fail <| "Unknown slideType " ++ unknown
