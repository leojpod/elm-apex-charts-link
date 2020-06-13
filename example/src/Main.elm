port module Main exposing (main)

import Browser
import Html exposing (Html, div)
import Html.Attributes exposing (class, id)
import Json.Encode
import Platform exposing (Program)


type alias Login = 
  { user: String
  , date: Time.Posix
  }

type alias Model =
    { logins : List Login
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
    div [ class "container flex flex-col" ]
        [ div [ id "chart1" ] []
        , div [ id "chart2" ] []
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


port updateChart : Json.Encode.Value -> Cmd msg
