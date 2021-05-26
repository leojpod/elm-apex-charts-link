module Apex exposing
    ( encodeChart
    , apexChart
    , fromPlotChart, fromRoundChart
    )

{-| This package provide a (WIP) integration between elm and [Apex charts](https://apexcharts.com/) via either custom-element or ports.

The main thing this package does is provide a simple and declarative way to describe a chart and encode it so that it can directly be picked up by Apex Charts.

Note, this package comes with an "already made" custom component which you can install and use via the node package version of `elm-apex-charts-link` (see the README).

Here is how you would describe a simple chart with some options (checkout the example project for more use-cases):

        import Apex

        myChart : Html Msg
        myChart =
            Apex.apexChart
                (Apex.chart
                    |> Apex.addLineSeries "Connections by week" (connectionsByWeek logins)
                    |> Apex.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                    |> Apex.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                    |> Apex.withXAxisType Apex.DateTime
                )
                []
                []


# When should I use this package?

For that please refer to the [README](./) page


# Creating charts


# Entry point

@docs chart


## Adding data

@docs Point

@docs addLineSeries

@docs addColumnSeries


## Configuring the display

@docs withLegends

@docs withXAxisType

@docs XAxisType

NOTE: A lot more support for options and type of series needs to be added


# Rendering charts

To render your chart you have 2 options:

  - encode it to JSON and send it to via a port to be rendered via JavaScript/TypeScript.

```elm
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
```

```js
app.ports.updateChart.subscribe((chartDescription) => {
  const chart = new ApexCharts(
    document.querySelector('#chart1'),
    chartDescription
  )
  chart.render()
})
```

@docs encodeChart

  - use `npm install elm-apex-charts-link` to gain access to the custom element and then use:

         import Apex

         myChart : Html Msg
         myChart =
             Apex.apexChart
                 (Apex.chart
                     |> Apex.addLineSeries "Connections by week" (connectionsByWeek logins)
                     |> Apex.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                     |> Apex.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                     |> Apex.withXAxisType Apex.DateTime
                 )
                 []
                 []

@docs apexChart

-}

import Charts.Plots exposing (PlotChart)
import Charts.RoundCharts exposing (RoundChart)
import Html exposing (Html)
import Html.Attributes
import Json.Encode


{-| This is an internal type to make sure we're keeping the definitions and list handling coherent and free from outside manipulation
-}
type Chart
    = PlotChart_ PlotChart
    | RoundChart_ RoundChart


fromPlotChart : PlotChart -> Chart
fromPlotChart =
    PlotChart_


fromRoundChart : RoundChart -> Chart
fromRoundChart =
    RoundChart_



{--_Encoding part --}


{-| this function takes a chart and turns it into JSON data that Apex Charts can understand

NOTE: if you are using the custom-element version you should not need to use this function

-}
encodeChart : Chart -> Json.Encode.Value
encodeChart chart =
    case chart of
        RoundChart_ roundChart ->
            Apex.RoundChart.encode roundChart

        PlotChart_ plotChart ->
            Apex.Plots.encode plotChart


encodeChart_ : ChartSeries -> Options -> Json.Encode.Value
encodeChart_ allSeries options =
    Json.Encode.object <|
        (( "series", Json.Encode.list encodeSeries allSeries )
            :: encodeEachOptions options
        )


encodeSingleSeriesChart : String -> SingleSeriesData -> Options -> Json.Encode.Value
encodeSingleSeriesChart _ series options =
    Json.Encode.object <|
        [ ( "labels"
          , Json.Encode.list Json.Encode.string <|
                Tuple.first <|
                    List.unzip series
          )
        , ( "series"
          , Json.Encode.list Json.Encode.float <|
                Tuple.second <|
                    List.unzip series
          )
        ]
            ++ encodeEachOptions options


encodeEachOptions : Options -> List ( String, Json.Encode.Value )
encodeEachOptions options =
    [ ( "noData", Json.Encode.object [ ( "text", Json.Encode.string options.noData ) ] )
    , ( "chart", encodeChartOptions options.chart )
    , ( "dataLabels", Json.Encode.object [ ( "enabled", Json.Encode.bool options.dataLabels ) ] )
    , ( "stroke", encodeStrokeOptions options.stroke )
    , ( "grid", encodeGridOptions options.grid )
    , ( "legend", encodeLegendOptions options.legend )
    , ( "xaxis", encodeXAxisOptions options.xAxis )
    ]


encodeSeries : Series -> Json.Encode.Value
encodeSeries series =
    case series of
        Single _ data ->
            Json.Encode.object
                [ ( "data"
                  , Json.Encode.list Json.Encode.float <|
                        Tuple.second <|
                            List.unzip data
                  )
                ]

        Paired name type_ dataPoints ->
            Json.Encode.object
                [ ( "name", Json.Encode.string name )
                , ( "type"
                  , case type_ of
                        Lines ->
                            Json.Encode.string "line"

                        Columns ->
                            Json.Encode.string "column"
                  )
                , ( "data"
                  , Json.Encode.list encodePoint dataPoints
                  )
                ]


encodePoint : Point -> Json.Encode.Value
encodePoint { x, y } =
    Json.Encode.object [ ( "x", Json.Encode.float x ), ( "y", Json.Encode.float y ) ]


encodeStrokeOptions : StokeOptions -> Json.Encode.Value
encodeStrokeOptions { curve, show, width } =
    Json.Encode.object
        [ ( "curve", Json.Encode.string curve )
        , ( "show", Json.Encode.bool show )
        , ( "width", Json.Encode.int width )
        ]


encodeGridOptions : GridOptions -> Json.Encode.Value
encodeGridOptions show =
    if show then
        Json.Encode.object []

    else
        Json.Encode.object
            [ ( "show", Json.Encode.bool False )
            , ( "padding"
              , Json.Encode.object
                    [ ( "left", Json.Encode.int 0 )
                    , ( "right", Json.Encode.int 0 )
                    , ( "top", Json.Encode.int 0 )
                    ]
              )
            ]


encodeLegendOptions : LegendOptions -> Json.Encode.Value
encodeLegendOptions show =
    Json.Encode.object [ ( "show", Json.Encode.bool show ) ]


encodeChartOptions : ChartOptions -> Json.Encode.Value
encodeChartOptions { type_, toolbar, zoom } =
    Json.Encode.object <|
        [ ( "width", Json.Encode.string "100%" )
        , ( "toolbar", Json.Encode.object [ ( "show", Json.Encode.bool toolbar ) ] )
        , ( "zoom", Json.Encode.object [ ( "enabled", Json.Encode.bool zoom ) ] )
        ]
            ++ (case type_ of
                    Unset ->
                        []

                    Infered value ->
                        [ ( "type", value |> Json.Encode.string ) ]

                    Set "" ->
                        []

                    Set value ->
                        [ ( "type", value |> Json.Encode.string ) ]
               )


encodeXAxisOptions : XAxisOptions -> Json.Encode.Value
encodeXAxisOptions type_ =
    Json.Encode.object
        [ ( "type"
          , Json.Encode.string <|
                case type_ of
                    Category ->
                        "category"

                    DateTime ->
                        "datetime"

                    Numeric ->
                        "numeric"
          )
        ]



{--Interop area --}


{-| this is the custom element wrapper.
Make sure that you have installed the javascript companion package (`npm i elm-apex-charts-link`) before using this function!
-}
apexChart : Chart -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
apexChart aChart extraAttributes =
    Html.node "apex-chart"
        ((Html.Attributes.property "data" <|
            encodeChart aChart
         )
            :: extraAttributes
        )
