import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App exposing (program, map)
import Slides
import Modal

type alias Model =
    { slides : Slides.Model
    , newSlide : Modal.Model
    }

init : (Model, Cmd Msg)
init =
    let
        (slides, slidesCmd) = Slides.init
        (newSlide, newSlideCmd) = Modal.init
    in
        ( Model slides newSlide
        , Cmd.batch
            [ Cmd.map SlideList slidesCmd
            , Cmd.map NewSlide newSlideCmd
            ]
        )


type Msg
    = SlideList Slides.Msg
    | NewSlide Modal.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SlideList msg ->
            let
                (slides, cmd) = Slides.update msg model.slides
            in
                ({model | slides = slides}, Cmd.map SlideList cmd)

        NewSlide msg ->
            let
                (newSlide, newSlideCmd) = Modal.update msg model.newSlide
            in
                ({model | newSlide = newSlide}, Cmd.map NewSlide newSlideCmd)

view : Model -> Html Msg
view model =
    let
        newSlide = map NewSlide <| Modal.view model.newSlide
        slides = List.map (\slide -> map SlideList slide) <| Slides.view model.slides
    in
        div []
            [ h1 [] [ text "Switcharoo" ]
            , ul [ class "slides" ]
                <| newSlide :: slides
            ]

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map NewSlide <| Modal.subscriptions model.newSlide ]

main : Program Never
main = program {init = init, view = view, update = update, subscriptions = subscriptions}
