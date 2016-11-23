module Models.Program exposing (Model, view, decoder)

import Html exposing (Html, map, div, h1, ul, text)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, list, map2, field, string)
import Models.Slot as Slot


type alias Model =
    { presentations : List Slot.Model
    , heading : String
    }


type Msg
    = Update


decoder : Decoder Model
decoder =
    map2 Model (field "presentations" <| list Slot.decoder) (field "heading" string)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Update ->
            model


view : Model -> Html Msg
view model =
    div [ class "slides__slide program" ]
        [ h1 [ class "program__header" ]
            [ text model.heading ]
        , ul [ class "program__program" ] <|
            List.map (\entry -> map (\_ -> Update) (Slot.view entry)) model.presentations
        ]
