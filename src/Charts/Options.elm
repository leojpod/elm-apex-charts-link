module Charts.Options exposing
    ( Options
    , default
    , withLegends
    )

{-
   # Stuff to put here one day:

     - interactivity
     - some sort of event handling?
     - datalabel stuff
     - colors and stuff
     - i18n
     - tooltips?
     - legend
     - noData
-}


type alias Options =
    { zoom : Bool
    , toolbar : Bool
    , legends : Bool
    }


default : Options
default =
    { zoom = False
    , toolbar = False
    , legends = False
    }


withLegends : Bool -> Options -> Options
withLegends bool options =
    { options | legends = bool }
