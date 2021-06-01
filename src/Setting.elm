module Setting exposing
    ( Setting(..)
    , mapInferred
    , set
    )


type Setting a
    = Unset
    | Inferred a
    | Set a


mapInferred : (a -> a) -> Setting a -> Setting a
mapInferred mapFct setting =
    case setting of
        Inferred a ->
            Inferred <| mapFct a

        _ ->
            setting


set : a -> Setting a -> Setting a
set a _ =
    Set a
