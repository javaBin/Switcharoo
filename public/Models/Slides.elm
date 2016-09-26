module Models.Slides exposing (..)

import Html.App as App
import List exposing (length)
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Json.Decode exposing (Decoder, andThen, succeed, list, string, object1, fail, (:=))
import Models.Info as Info
import Models.Tweets as Tweets
import Models.Program as Program
import Models.Votes as Votes
import Time exposing (Time, second, millisecond)
import Task
import Process exposing (sleep)

type alias Model =
    { slides : List SlideWrapper
    , index : Int
    , switching : Bool
    }

init : Model
init = Model [] 0 False

type SlideWrapper
    = InfoWrapper Info.Model
    | TweetsWrapper Tweets.Model
    | ProgramWrapper Program.Model
    | VotesWrapper Votes.Model

type Msg
    = Update
    -- | VotesMsg Votes.Msg
    -- | ResetVotes
    | NextSlide
    | HideSlide
    | ShowSlide

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Update ->
            (model, Cmd.none)

        -- VotesMsg votesMsg ->
        --     case getVotes model of
        --         Just s ->
        --             let
        --                 newVotes = Votes.update votesMsg s
        --             in
        --                 {model | slides = List.map (\cur -> updateVotes cur newVotes) model.slides}
        --         Nothing ->
        --             (model, Cmd.none)

        -- ResetVotes ->
        --     case getVotes model of
        --         Just s ->
        --             let
        --                 newVotes = Votes.update Votes.Reset s
        --             in
        --                 {model | slides = List.map(\cur -> updateVotes cur newVotes) model.slides}
        --         Nothing ->
        --             (model, Cmd.none)

        HideSlide ->
            let
                nextIndex = getNextIndex model
                shouldChange = length model.slides > 1
            in
                if shouldChange then
                    ({model | switching = True}, hideSlide)
                else
                    (model, hideSlide)

        NextSlide ->
            let
                nextIndex = getNextIndex model
            in
                ({model | index = nextIndex}, showSlide)

        ShowSlide ->
            ({model | switching = False}, Cmd.none)

hideSlide : Cmd Msg
hideSlide = Task.perform (\_ -> NextSlide) (\_ -> NextSlide) <| sleep (500 * millisecond)

showSlide : Cmd Msg
showSlide = Task.perform (\_ -> ShowSlide) (\_ -> ShowSlide) <| sleep (500 * millisecond)

updateVotes : SlideWrapper -> Votes.Model -> SlideWrapper
updateVotes cur new =
    case cur of
        VotesWrapper _ -> VotesWrapper new
        _ -> cur

slides : Decoder (List SlideWrapper)
slides = ("slides" := slideWrapperList)

slideWrapperList : Decoder (List SlideWrapper)
slideWrapperList = list (("type" := string) `andThen` slideWrapper)

slideWrapper : String -> Decoder SlideWrapper
slideWrapper t =
    case t of
        "text" -> Info.info `andThen` (\s -> succeed <| InfoWrapper s)
        "image" -> Info.info `andThen` (\s -> succeed <| InfoWrapper s)
        "video" -> Info.info `andThen` (\s -> succeed <| InfoWrapper s)
        "tweets" -> Tweets.tweets `andThen` (\s -> succeed <| TweetsWrapper s)
        "program" -> Program.decoder `andThen` (\s -> succeed <| ProgramWrapper s)
        "votes" -> Votes.decoder `andThen` (\s -> succeed <| VotesWrapper s)
        t' -> fail <| "Unknown slideType " ++ t'

view : Model -> Html Msg
view model =
    let
        slide = getAt model.index model.slides
    in
        div [ classList [("switcharoo", True), ("switcharoo--hidden", model.switching)] ]
            [
              case slide of
                  Just s -> viewSlide s
                  Nothing -> text ""
            ]

viewSlide : SlideWrapper -> Html Msg
viewSlide slide =
    case slide of
        InfoWrapper s -> App.map (\_ -> Update) (Info.view s)
        TweetsWrapper s -> App.map (\_ -> Update) (Tweets.view s)
        ProgramWrapper s -> App.map (\_ -> Update) (Program.view s)
        VotesWrapper s -> App.map (\_ -> Update) (Votes.view s)

isVotes : SlideWrapper -> Maybe Votes.Model -> Maybe Votes.Model
isVotes s old =
    case s of
        VotesWrapper s2 -> Just s2
        _ -> old

subscriptions : Model -> Sub Msg
subscriptions model = Time.every (10 * second) (\_ -> HideSlide)

getAt : Int -> List a -> Maybe a
getAt idx = List.head << List.drop idx

getNextIndex : Model -> Int
getNextIndex model =
    if model.index + 1 == length model.slides then
        0
    else
        model.index + 1
