port module Main exposing (main)

import Apex
import Browser
import Charts.Bar as Bar
import Charts.Plot as Plot
import Charts.RoundChart as RoundChart
import FakeData
import Html exposing (Html, div, h1, text)
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
    , { user = "Jane doe", date = Time.Extra.add Time.Extra.Week -2 zone now, os = Linux, place = "Home" }
    , { user = "Jane doe", date = Time.Extra.add Time.Extra.Day -2 zone now, os = Linux, place = "Office" }
    , { user = "Jane doe"
      , date = Time.Extra.add Time.Extra.Hour -3 zone <| Time.Extra.add Time.Extra.Day -6 zone now
      , os = Linux
      , place = "Office"
      }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -3 zone now, os = Linux, place = "Office" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -2 zone now, os = Linux, place = "Commuting" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -9 zone now, os = Linux, place = "Commuting" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -9 zone now, os = Linux, place = "Home" }
    , { user = "Jon doe", date = Time.Extra.add Time.Extra.Hour 3 zone <| Time.Extra.add Time.Extra.Day -3 zone now, os = Linux, place = "Home" }
    ]


type alias Model =
    { logins :
        List Login
    , yearlyUsage : List FakeData.Usage
    , stateReport : FakeData.StateReport
    }


type Msg
    = LoadFakeLogins Time.Posix
    | UpdateNow Time.Posix
    | LoadYearlyUsage (List FakeData.Usage)
    | LoadStateReport FakeData.StateReport


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
    ( { logins = []
      , yearlyUsage = []
      , stateReport = FakeData.StateReport 0 0 0
      }
    , Cmd.batch
        [ Time.now |> Task.perform LoadFakeLogins
        , Time.now |> Task.perform UpdateNow
        , FakeData.fakeStateReport LoadStateReport
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadFakeLogins now ->
            let
                logins =
                    fictiveLogins Time.utc now
            in
            ( { model | logins = logins }
            , Cmd.none
            )

        UpdateNow now ->
            ( model, FakeData.fakeYearlyUsage Time.utc now LoadYearlyUsage )

        LoadYearlyUsage usages ->
            ( { model | yearlyUsage = usages }
            , updateChart <|
                Apex.encodeChart <|
                    (Plot.plot
                        |> Plot.addColumnSeries "Time used" (usagesByMonth usages)
                        |> Plot.withXAxisType Plot.DateTime
                        |> Apex.fromPlotChart
                        |> Apex.withColors [ "#5C4742" ]
                    )
            )

        LoadStateReport stateReport ->
            ( { model | stateReport = stateReport }, Cmd.none )


connectionsByWeek : List Login -> List Plot.Point
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


usagesByMonth : List FakeData.Usage -> List Plot.Point
usagesByMonth =
    List.Extra.gatherEqualsBy (Time.Extra.floor Time.Extra.Month Time.utc)
        >> List.map
            (\( head, list ) ->
                { x =
                    head
                        |> Time.Extra.floor Time.Extra.Month Time.utc
                        |> Time.posixToMillis
                        |> toFloat
                , y = (head :: list) |> List.length |> toFloat
                }
            )
        >> List.sortBy .x


dayTimeConnectionByWeek : List Login -> List Plot.Point
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


outsideOfficeHourConnectionByWeek : List Login -> List Plot.Point
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


connectionsByHourOfTheDay : List Login -> List Plot.Point
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


view : Model -> Html Msg
view { logins, stateReport } =
    let
        defaultChart =
            Plot.plot
                |> Plot.addLineSeries "Connections by week" (connectionsByWeek logins)
                |> Plot.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                |> Plot.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                |> Plot.withXAxisType Plot.DateTime
                |> Apex.fromPlotChart
                |> Apex.withColors [ "#ff2E9B", "#3f51b5", "#7700D0" ]
    in
    div [ class "min-h-screen bg-gray-100" ]
        [ div [ class "max-w-3xl p-1 p-12 mx-auto bg-white shadow-2xl rounded-xl grid grid-cols-1 gap-4 md:grid-cols-3" ]
            [ div [ id "chart1", class "col-span-1 md:col-span-3" ] [ div [] [] ]
            , Apex.apexChart
                [ class "col-span-1 md:col-span-2" ]
                (RoundChart.pieChart "State"
                    [ ( "working", stateReport.working |> toFloat )
                    , ( "meeh", stateReport.meeh |> toFloat )
                    , ( "not working", stateReport.notWorking |> toFloat )
                    ]
                    |> Apex.fromRoundChart
                    |> Apex.withColors [ "#1B998B", "#E2C044", "#D7263D" ]
                )
            , div [ class "flex flex-col items-center" ]
                [ div [ class "flex flex-col items-center justify-center w-56 h-56 bg-red-400 rounded-full" ]
                    [ h1 [ class "text-xl font-bold text-white" ] [ text "56 " ]
                    , h1 [ class "font-bold text-gray-50 text-l" ] [ text "incidents" ]
                    ]
                , Apex.apexChart
                    [ class "col-span-1" ]
                    (RoundChart.radialBar "Time boooked" [ ( "room 1", 80 ) ]
                        |> RoundChart.withCustomAngles -90 90
                        |> Apex.fromRoundChart
                        |> Apex.withColors [ "#A300D6" ]
                    )
                ]
            , Apex.apexChart [ class "col-span-1" ]
                (Bar.bar
                    |> Bar.addSeries "day time" [ ( "abc", 10 ), ( "def", 30 ), ( "ghi", 2 ), ( "jkl", 12 ) ]
                    |> Bar.addSeries "night time" [ ( "abc", 1 ), ( "def", 2.5 ), ( "ghi", 20 ), ( "jkl", 22 ) ]
                    |> Bar.isHorizontal
                    |> Bar.isStacked
                    |> Apex.fromBarChart
                    |> Apex.withColors [ "#00B1F2", "#546E7A", "#F86624", "#E2C044" ]
                )
            , Apex.apexChart [ class "col-span-2" ] defaultChart
            ]
        ]
