module Main exposing (..)

import Html exposing (Html, programWithFlags, map, div, button, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Admin.Model
import Admin.Messages
import Admin.View
import Admin.Update
import Admin.Subscriptions
import Auth


type alias Flags =
    { loggedIn : Bool
    }


type alias Model =
    { admin : Admin.Model.Model
    , auth : Auth.AuthStatus
    , flags : Flags
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( admin, adminCmd ) =
            Admin.Model.initModel
    in
        ( Model admin Auth.LoggedOut flags, Cmd.batch [ Cmd.map AdminMsg adminCmd ] )


type Msg
    = Login
    | LoginResult Auth.UserData
    | AdminMsg Admin.Messages.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AdminMsg msg ->
            let
                ( admin, cmd ) =
                    Admin.Update.update msg model.admin

                mappedCmd =
                    Cmd.map AdminMsg cmd
            in
                ( { model | admin = admin }, mappedCmd )

        Login ->
            ( model, Auth.login () )

        LoginResult userData ->
            ( { model | auth = Auth.LoggedIn userData }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.auth of
        Auth.LoggedOut ->
            loginView model

        Auth.LoggedIn _ ->
            Html.map AdminMsg <| Admin.View.view model.admin


loginView : Model -> Html Msg
loginView model =
    div [ class "login" ]
        [ button [ onClick Login ] [ text "Logg inn" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map AdminMsg <| Admin.Subscriptions.subscriptions model.admin
        , Auth.loginResult LoginResult
        ]


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
