port module Main exposing (main)

import Apex
import Browser
import Html exposing (Html, div)
import Html.Attributes exposing (class, id)
import Json.Encode
import List.Extra
import Platform exposing (Program)
import Task
import Time
import Time.Extra


type alias Login =
    { user : String
    , date : Time.Posix
    , os : OS
    , place : String
    }


type OS
    = Linux
    | MacOS
    | BSD
    | Other


fictiveLogins : Time.Zone -> Time.Posix -> List Login
fictiveLogins zone now =
    [ { user = "Jane doe", date = now, os = Linux, place = "Home" }
    , { user = "Jane doe", date = Time.Extra.add Time.Extra.Hour -2 zone now, os = Linux, place = "Home" }
    , { user = "Jane doe", date = Time.Extra.add Time.Extra.Hour -8 zone now, os = Linux, place = "Home" }
    , { user = "Jane doe", date = Time.Extra.add Time.Extra.Day -2 zone now, os = Linux, place = "Office" }
    , { user = "Jane doe", date = Time.Extra.add Time.Extra.Hour -3 zone <| Time.Extra.add Time.Extra.Day -3 zone now, os = Linux, place = "Office" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -3 zone now, os = Linux, place = "Office" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -2 zone now, os = Linux, place = "Commuting" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -3 zone now, os = Linux, place = "Commuting" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -3 zone now, os = Linux, place = "Home" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -3 zone now, os = Linux, place = "Home" }
    ]


type alias Model =
    List Login


type Msg
    = LoadFakeLogins Time.Posix


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
    ( []
    , Time.now |> Task.perform LoadFakeLogins
    )


view : Model -> Html Msg
view _ =
    div [ class "container flex flex-col" ]
        [ div [ id "chart1" ] []
        , div [ id "chart2" ] []
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadFakeLogins now ->
            let
                logins =
                    fictiveLogins Time.utc now
            in
            ( logins
            , updateChart <|
                Apex.encodeChart <|
                    Apex.LineChart <|
                        connectionsByWeek logins
            )


connectionsByWeek : List Login -> List Apex.Point
connectionsByWeek =
    List.Extra.gatherEqualsBy (.date >> Time.Extra.floor Time.Extra.Week Time.utc)
        >> List.map
            (\( head, list ) ->
                { x = head.date |> Time.Extra.floor Time.Extra.Week Time.utc
                |> Time.posixToMillis 
                |> toFloat
                , y = (head :: list) |> List.length |> toFloat
                }
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


port updateChart : Json.Encode.Value -> Cmd msg
