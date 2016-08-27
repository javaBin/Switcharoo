import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App exposing (program, map)
import Slides
import Debug exposing (log)

type alias Model =
    { slides : Slides.Model
    }

init : (Model, Cmd Msg)
init =
    let
        (slides, slidesCmd) = Slides.init
    in
        ( Model slides
        , Cmd.map SlideList slidesCmd
        )

type Msg
    = SlideList Slides.Msg
    -- | NewSlide Modal.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    log ("Main: " ++ toString msg) <|
    case msg of
        SlideList msg ->
            let
                (slides, cmd) = Slides.update msg model.slides
            in
                ({model | slides = slides}, Cmd.map SlideList cmd)

view : Model -> Html Msg
view model =
    let
        slides = List.map (\slide -> map SlideList slide) <| Slides.view model.slides
    in
        div []
            [ h1 [] [ text "Switcharoo" ]
            , ul [ class "slides" ]
                <| slides
            ]

subscriptions : Model -> Sub Msg
subscriptions model = Sub.map SlideList <| Slides.subscriptions model.slides

main : Program Never
main = program {init = init, view = view, update = update, subscriptions = subscriptions}
