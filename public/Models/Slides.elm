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
import List.Zipper as Z


type alias Model =
    { switching : Bool
    , slides : Z.Zipper SlideWrapper
    }


init : Model
init =
    fromList []


fromList : List SlideWrapper -> Model
fromList =
    Model False << Z.withDefault (InfoWrapper Info.empty) << Z.fromList


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update ->
            ( model, Cmd.none )

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
                shouldChange =
                    zipperLength model.slides > 1
            in
                if shouldChange then
                    ( { model | switching = True }, hideSlide )
                else
                    ( model, Cmd.none )

        NextSlide ->
            case Z.next model.slides of
                Just z ->
                    ( { model | slides = z }, showSlide )

                Nothing ->
                    ( { model | slides = Z.first model.slides }, showSlide )

        ShowSlide ->
            ( { model | switching = False }, Cmd.none )


hideSlide : Cmd Msg
hideSlide =
    Task.perform (\_ -> NextSlide) (\_ -> NextSlide) <| sleep (500 * millisecond)


showSlide : Cmd Msg
showSlide =
    Task.perform (\_ -> ShowSlide) (\_ -> ShowSlide) <| sleep (500 * millisecond)


slides : Decoder (List SlideWrapper)
slides =
    ("slides" := slideWrapperList)


slideWrapperList : Decoder (List SlideWrapper)
slideWrapperList =
    list (("type" := string) `andThen` slideWrapper)


slideWrapper : String -> Decoder SlideWrapper
slideWrapper t =
    case t of
        "text" ->
            Info.info `andThen` (succeed << InfoWrapper)

        "image" ->
            Info.info `andThen` (succeed << InfoWrapper)

        "video" ->
            Info.info `andThen` (succeed << InfoWrapper)

        "tweets" ->
            Tweets.tweets `andThen` (succeed << TweetsWrapper)

        "program" ->
            Program.decoder `andThen` (succeed << ProgramWrapper)

        "votes" ->
            Votes.decoder `andThen` (succeed << VotesWrapper)

        unknown ->
            fail <| "Unknown slideType " ++ unknown


view : Model -> Html Msg
view model =
    let
        slide =
            Z.current model.slides
    in
        div [ classList [ ( "switcharoo", True ), ( "switcharoo--hidden", model.switching ) ] ]
            [ viewSlide slide ]


viewSlide : SlideWrapper -> Html Msg
viewSlide slide =
    case slide of
        InfoWrapper s ->
            App.map (\_ -> Update) (Info.view s)

        TweetsWrapper s ->
            App.map (\_ -> Update) (Tweets.view s)

        ProgramWrapper s ->
            App.map (\_ -> Update) (Program.view s)

        VotesWrapper s ->
            App.map (\_ -> Update) (Votes.view s)


isVotes : SlideWrapper -> Maybe Votes.Model -> Maybe Votes.Model
isVotes s old =
    case s of
        VotesWrapper s2 ->
            Just s2

        _ ->
            old


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every (10 * second) (\_ -> HideSlide)


updateIfPossible : Model -> Maybe Model -> Model
updateIfPossible current new =
    case Z.next current.slides of
        Just _ ->
            current

        Nothing ->
            case new of
                Just n ->
                    n

                Nothing ->
                    current


zipperLength : Z.Zipper a -> Int
zipperLength =
    length << Z.toList
