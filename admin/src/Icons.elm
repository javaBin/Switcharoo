module Icons exposing (..)

import Html exposing (Html, i, text)
import Html.Attributes exposing (class)


slidesIcon : Html msg
slidesIcon =
    icon "view_module"


settingsIcon : Html msg
settingsIcon =
    icon "settings"


brushIcon : Html msg
brushIcon =
    icon "brush"


keyboardArrowLeftIcon : Html msg
keyboardArrowLeftIcon =
    icon "keyboard_arrow_left"


deleteIcon : Html msg
deleteIcon =
    icon "delete"


editIcon : Html msg
editIcon =
    icon "mode_edit"


icon : String -> Html msg
icon name =
    i [ class "material-icons" ] [ text name ]
