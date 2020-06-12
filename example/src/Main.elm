module Main exposing (main)

import Browser
import Html.Attributes exposing (class)
import Html exposing (Html, div)
import Platform exposing (Program)


type alias Model =
    { data1 : ()
    , data2 : ()
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
    ( { data1 = ()
      , data2 = ()
      }
    , Cmd.none
    )


view : Model -> Html Msg
view _ =
    div [ class "container" ] [] []


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
