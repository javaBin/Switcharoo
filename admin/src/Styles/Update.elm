module Styles.Update exposing (update)

import Styles.Model exposing (..)
import Styles.Messages exposing (..)
import Css.Messages
import Css.Model
import Css.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CssMsg style cssMsg ->
            let
                ( newStyles, newCmds ) =
                    List.unzip (List.map (updateStyle style cssMsg) model.styles)
            in
                ( { model | styles = newStyles }, Cmd.batch newCmds )

        GotStyles (Err err) ->
            ( model, Cmd.none )

        GotStyles (Ok styles) ->
            ( { model | styles = styles }, Cmd.none )


updateStyle : Css.Model.Model -> Css.Messages.Msg -> Css.Model.Model -> ( Css.Model.Model, Cmd Msg )
updateStyle newModel msg currentModel =
    if newModel.id == currentModel.id then
        let
            ( newStyle, newCmd ) =
                Css.Update.update msg newModel
        in
            ( newStyle, Cmd.map (CssMsg newStyle) newCmd )
    else
        ( currentModel, Cmd.none )
