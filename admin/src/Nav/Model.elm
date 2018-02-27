module Nav.Model exposing (Page(..), ConferencePage(..))


type ConferencePage
    = SlidesPage
    | SettingsPage
    | StylesPage


type Page
    = LoggedOutPage
    | ConferencesPage
    | ConferencePage Int ConferencePage
