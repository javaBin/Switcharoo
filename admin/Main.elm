import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App exposing (program, map)
import Slides
import Settings
import Debug exposing (log)

type alias Model =
    { slides : Slides.Model
    , settings : Settings.Model
    }

init : (Model, Cmd Msg)
init =
    let
        (slides, slidesCmd) = Slides.init
        (settings, settingsCmd) = Settings.init
    in
        ( Model slides settings
        , Cmd.batch [ Cmd.map SlideList slidesCmd
                    , Cmd.map SettingsMsg settingsCmd
                    ]
        )

type Msg
    = SlideList Slides.Msg
    | SettingsMsg Settings.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    log ("Main: " ++ toString msg) <|
    case msg of
        SlideList msg ->
            let
                (slides, cmd) = Slides.update msg model.slides
            in
                ({model | slides = slides}, Cmd.map SlideList cmd)

        SettingsMsg msg ->
            let
                (settings, cmd) = Settings.update msg model.settings
            in
                ({model | settings = settings}, Cmd.map SettingsMsg cmd)

view : Model -> Html Msg
view model =
    let
        slides = List.map (\slide -> map SlideList slide) <| Slides.view model.slides
        settings = map SettingsMsg <| Settings.view model.settings
    in
        div []
            [ h1 [] [ text "Switcharoo" ]
            , settings
            , ul [ class "slides" ]
                <| slides
            ]

subscriptions : Model -> Sub Msg
subscriptions model = Sub.map SlideList <| Slides.subscriptions model.slides

main : Program Never
main = program {init = init, view = view, update = update, subscriptions = subscriptions}
