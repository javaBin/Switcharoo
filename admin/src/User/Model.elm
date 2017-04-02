module User.Model exposing (Model, initModel)


type alias Model =
    { email : String
    , email_verified : Bool
    , picture : String
    }


initModel : Model
initModel =
    Model "" False ""
