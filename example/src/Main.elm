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
import FakeData
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
    , { user = "Jane doe", date = Time.Extra.add Time.Extra.Week -2 zone now, os = Linux, place = "Home" }
    , { user = "Jane doe", date = Time.Extra.add Time.Extra.Day -2 zone now, os = Linux, place = "Office" }
    , { user = "Jane doe"
    , date = Time.Extra.add Time.Extra.Hour -3 zone <| Time.Extra.add Time.Extra.Day -6 zone now, os = Linux, place = "Office" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -3 zone now, os = Linux, place = "Office" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -2 zone now, os = Linux, place = "Commuting" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -9 zone now, os = Linux, place = "Commuting" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -9 zone now, os = Linux, place = "Home" }
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
view logins =
    let 
        defaultChart = 
                (Apex.chart
                    |> Apex.addLineSeries "Connections by week" (connectionsByWeek logins)
                    |> Apex.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                    |> Apex.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                    |> Apex.withXAxisType Apex.DateTime
                )
    in
    div [ class "container grid grid-cols-1 gap-4 md:grid-cols-3" ]
    [ div [id "chart1", class "col-span-1 md:col-span-3"] [ div []  []]
    , Apex.apexChart defaultChart [ class "col-span-1 md:col-span-2" ] []
    , Apex.apexChart defaultChart [ class "col-span-1" ] []
    , Apex.apexChart defaultChart [ class "col-span-1" ] []
    ]
    {--[ div [ class "w-1/2 mx-auto" ]
            [ div [ id "chart1", class "bg-gray-400 min-h-64" ]
                [ div [] []
                ]
            ]
        , div [ class "flex flex-col flex-grow" ]
            [ div [ class "w-full h-8" ] []
            ]
        , div [ class "w-1/2 mx-auto" ]
            [ Apex.apexChart
                (Apex.chart
                    |> Apex.addLineSeries "Connections by week" (connectionsByWeek logins)
                    |> Apex.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                    |> Apex.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                    |> Apex.withXAxisType Apex.DateTime
                )
                []
                []
            ]
        ]
        -}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        LoadFakeLogins now ->
            let
                logins =
                    fictiveLogins Time.utc now
            in
            ( logins
            , updateChart <|
                Apex.encodeChart <|
                    (Apex.chart
                        |> Apex.addLineSeries "Connections by week" (connectionsByWeek logins)
                        |> Apex.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                        |> Apex.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                        |> Apex.withXAxisType Apex.DateTime
                    )
            )


connectionsByWeek : List Login -> List Apex.Point
connectionsByWeek =
    List.Extra.gatherEqualsBy (.date >> Time.Extra.floor Time.Extra.Week Time.utc)
        >> List.map
            (\( head, list ) ->
                { x =
                    head.date
                        |> Time.Extra.floor Time.Extra.Week Time.utc
                        |> Time.posixToMillis
                        |> toFloat
                , y = (head :: list) |> List.length |> toFloat
                }
            )
        >> List.sortBy .x


dayTimeConnectionByWeek : List Login -> List Apex.Point
dayTimeConnectionByWeek =
    List.Extra.gatherEqualsBy (.date >> Time.Extra.floor Time.Extra.Week Time.utc)
        >> List.map
            (\( head, list ) ->
                { x =
                    head.date
                        |> Time.Extra.floor Time.Extra.Week Time.utc
                        |> Time.posixToMillis
                        |> toFloat
                , y =
                    (head :: list)
                        |> List.filter (.date >> Time.toHour Time.utc >> (\h -> h >= 8 && h < 18))
                        |> List.length
                        |> toFloat
                }
            )
        >> List.sortBy .x


outsideOfficeHourConnectionByWeek : List Login -> List Apex.Point
outsideOfficeHourConnectionByWeek =
    List.Extra.gatherEqualsBy (.date >> Time.Extra.floor Time.Extra.Week Time.utc)
        >> List.map
            (\( head, list ) ->
                { x =
                    head.date
                        |> Time.Extra.floor Time.Extra.Week Time.utc
                        |> Time.posixToMillis
                        |> toFloat
                , y =
                    (head :: list)
                        |> List.filter (.date >> Time.toHour Time.utc >> (\h -> h < 8 && h >= 18))
                        |> List.length
                        |> toFloat
                }
            )
        >> List.sortBy .x


connectionsByHourOfTheDay : List Login -> List Apex.Point
connectionsByHourOfTheDay =
    List.Extra.gatherEqualsBy (.date >> Time.toHour Time.utc)
        >> List.map
            (\( head, list ) ->
                { x =
                    head.date
                        |> Time.toHour Time.utc
                        |> toFloat
                , y = (head :: list) |> List.length |> toFloat
                }
            )
        >> List.sortBy .x


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


port updateChart : Json.Encode.Value -> Cmd msg
