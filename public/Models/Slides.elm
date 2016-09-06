module Models.Slides exposing (..)

import Html.App as App
import List exposing (length)
import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, andThen, succeed, list, string, object1, fail, (:=))
import Models.Info as Info
import Models.Tweets as Tweets
import Models.Program as Program
import Models.Votes as Votes

type alias Model =
    { slides : List SlideWrapper
    }

init : Model
init = Model []

type SlideWrapper
    = InfoWrapper Info.Model
    | TweetsWrapper Tweets.Model
    | ProgramWrapper Program.Model
    | VotesWrapper Votes.Model

type Msg
    = Update
    | VotesMsg Votes.Msg
    | ResetVotes

update : Msg -> Model -> Model
update msg model =
    case msg of
        Update ->
            model

        VotesMsg votesMsg ->
            case getVotes model of
                Just s ->
                    let
                        newVotes = Votes.update votesMsg s
                    in
                        {model | slides = List.map (\cur -> updateVotes cur newVotes) model.slides}
                Nothing ->
                    model

        ResetVotes ->
            case getVotes model of
                Just s ->
                    let
                        newVotes = Votes.update Votes.Reset s
                    in
                        {model | slides = List.map(\cur -> updateVotes cur newVotes) model.slides}
                Nothing ->
                    model

updateVotes : SlideWrapper -> Votes.Model -> SlideWrapper
updateVotes cur new =
    case cur of
        VotesWrapper _ -> VotesWrapper new
        _ -> cur

slides : Decoder Model
slides = object1 Model ("slides" := slideWrapperList)

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

view : Model -> Int -> Html Msg
view model idx =
    let
        slide = getAt idx model.slides
    in
        case slide of
            Just s -> viewSlide s
            Nothing -> div [ class "slides" ] [ text "" ]

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

getVotes : Model -> Maybe Votes.Model
getVotes model = List.foldl isVotes Nothing model.slides

subscriptions : Model -> Sub Msg
subscriptions model =
    case getVotes model of
        Just s -> Sub.map VotesMsg <| Votes.subscriptions s
        Nothing -> Sub.batch []

getAt : Int -> List a -> Maybe a
getAt idx = List.head << List.drop idx

getNextIndex : Int -> Model -> Int
getNextIndex idx model =
    if idx + 1 == length model.slides then
        0
    else
        idx + 1
