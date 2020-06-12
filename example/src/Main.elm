module Main exposing (main)

import Browser
import Html exposing (Html, div)
import Platform exposing (Program)


type alias Model =
    { stuff : ()
    , stoff : ()
    }


type Msg
    = NoOp


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( { stuff = ()
      , stoff = ()
      }
    , Cmd.none
    )


view : Model -> Html Msg
view _ =
    div [ class "" ] []


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
