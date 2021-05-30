module Apex exposing
    ( fromPlotChart
    , fromRoundChart
    , encodeChart
    , apexChart
    )

{-| This package provide a (WIP) integration between elm and [Apex charts](https://apexcharts.com/) via either custom-element or ports.

The main thing this package does is provide a simple and declarative way to describe a chart and encode it so that it can directly be picked up by Apex Charts.

Note, this package comes with an "already made" custom component which you can install and use via the node package version of `elm-apex-charts-link` (see the README).

Here is how you would describe a simple chart with some options (checkout the example project for more use-cases):

        import Apex
        import Charts.PlotChart as Plot

        myChart : Html Msg
        myChart =
            Apex.apexChart
                (Plot.plot
                    |> Plot.addLineSeries "Connections by week" (connectionsByWeek logins)
                    |> Plot.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                    |> Plot.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                    |> Plot.withXAxisType Plot.DateTime
                    |> Apex.fromPlotChart
                )
                []


# When should I use this package?

For that please refer to the [README](./) page


# Creating charts

Creating charts is done by using the Charts modules ([PlotChart](./Charts-PlotChart) & [RoundChart](./Charts-RoundChart))

Once you have a Chart you can transform it into an Apex chart with one of these 2 function

@docs fromPlotChart

@docs fromRoundChart


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
                    Apex.fromPlotChart <|
                        (Chart.PlotChart.chart
                            |> Chart.PlotChart.addLineSeries "Connections by week" (connectionsByWeek logins)
                            |> Chart.PlotChart.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                            |> Chart.PlotChart.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                            |> Chart.PlotChart.withXAxisType Chart.DateTime
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
                 (Chart.PlotChart.chart
                    |> Chart.PlotChart.addLineSeries "Connections by week" (connectionsByWeek logins)
                    |> Chart.PlotChart.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                    |> Chart.PlotChart.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                    |> Chart.PlotChart.withXAxisType Apex.DateTime
                    |> Apex.fromPlotChart
                 )
                 []

@docs apexChart

-}

import Apex.ChartDefinition exposing (ApexChart, ChartOptions, ChartType(..), CurveType(..), DataLabelOptions, GridOptions, LegendOptions, NoDataOptions, PairedSeries, Point, Series(..), SeriesType(..), StrokeOptions, XAxisOptions, XAxisType(..))
import Apex.PlotChart
import Apex.RoundChart
import Charts.PlotChart exposing (PlotChart)
import Charts.RoundChart exposing (RoundChart)
import Html exposing (Html)
import Html.Attributes
import Json.Encode


{-| This is an internal type to make sure we're keeping the definitions and list handling coherent and free from outside manipulation
-}
type Chart
    = Chart ApexChart


{-| One you have a nice plot chart reprensentation from [`Charts.PlotChart`](./Charts-PlotChart) you can transform it to an Apex chart by calling this function
-}
fromPlotChart : PlotChart -> Chart
fromPlotChart =
    Apex.PlotChart.toApex >> Chart


{-| One you have a nice pie/radial chart reprensentation from [`Charts.RoundChart`](./Charts-RoundChart) you can transform it to an Apex chart by calling this function
-}
fromRoundChart : RoundChart -> Chart
fromRoundChart =
    Apex.RoundChart.toApex >> Chart



{--_Encoding part --}


{-| this function takes a chart and turns it into JSON data that Apex Charts can understand

NOTE: if you are using the custom-element version you should not need to use this function

-}
encodeChart : Chart -> Json.Encode.Value
encodeChart (Chart chart) =
    encodeApexChart chart


encodeApexChart : ApexChart -> Json.Encode.Value
encodeApexChart { chart, legend, noData, dataLabels, labels, stroke, grid, xAxis, series } =
    Json.Encode.object <|
        [ ( "chart", encodeChartOptions chart )
        , ( "legend", encodeLegendOptions legend )
        , ( "noData", encodeNoDataOptions noData )
        , ( "dataLabels", encodeDataLabelsOptions dataLabels )
        , ( "stroke", encodeStrokeOptions stroke )
        , ( "grid", encodeGridOptions grid )
        , ( "series", encodeSeries series )
        ]
            ++ List.filterMap identity
                [ xAxis |> Maybe.map (\xaxisOptions -> ( "xaxis", encodeXAxisOptions xaxisOptions ))
                , labels |> Maybe.map (\labelsValues -> ( "labels", Json.Encode.list Json.Encode.string labelsValues ))
                ]


encodeLegendOptions : LegendOptions -> Json.Encode.Value
encodeLegendOptions show =
    Json.Encode.object [ ( "show", Json.Encode.bool show ) ]


encodeChartOptions : ChartOptions -> Json.Encode.Value
encodeChartOptions { type_, toolbar, zoom } =
    Json.Encode.object
        [ ( "width", Json.Encode.string "100%" )
        , ( "toolbar", Json.Encode.object [ ( "show", Json.Encode.bool toolbar ) ] )
        , ( "zoom", Json.Encode.object [ ( "enabled", Json.Encode.bool zoom ) ] )
        , ( "type", encodeChartType type_ )
        ]


encodeChartType : ChartType -> Json.Encode.Value
encodeChartType type_ =
    Json.Encode.string <|
        case type_ of
            Line ->
                "line"

            Area ->
                "area"

            Bar ->
                "bar"

            Pie ->
                "pie"

            Donut ->
                "donut"

            RadialBar ->
                "radialBar"


encodeNoDataOptions : NoDataOptions -> Json.Encode.Value
encodeNoDataOptions text =
    Json.Encode.object [ ( "text", Json.Encode.string text ) ]


encodeDataLabelsOptions : DataLabelOptions -> Json.Encode.Value
encodeDataLabelsOptions dataLabelsEnabled =
    Json.Encode.object [ ( "enabled", Json.Encode.bool dataLabelsEnabled ) ]


encodeStrokeOptions : StrokeOptions -> Json.Encode.Value
encodeStrokeOptions { curve, show, width } =
    Json.Encode.object
        [ ( "curve"
          , Json.Encode.string <|
                case curve of
                    Smooth ->
                        "smooth"

                    Strait ->
                        "strait"

                    Stepline ->
                        "stepline"
          )
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


encodeSeries : Series -> Json.Encode.Value
encodeSeries series =
    case series of
        SingleValueSeries values ->
            Json.Encode.list Json.Encode.float values

        PairedValueSeries pairedSeries ->
            Json.Encode.list encodePairedSeries pairedSeries


encodePairedSeries : PairedSeries -> Json.Encode.Value
encodePairedSeries { data, name, type_ } =
    Json.Encode.object <|
        [ ( "name", Json.Encode.string name )
        , ( "type"
          , Json.Encode.string <|
                case type_ of
                    LineSeries ->
                        "line"

                    ColumnSeries ->
                        "column"
          )
        , ( "data"
          , Json.Encode.list encodePoint data
          )
        ]


encodePoint : Point -> Json.Encode.Value
encodePoint { x, y } =
    Json.Encode.object [ ( "x", Json.Encode.float x ), ( "y", Json.Encode.float y ) ]


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
apexChart : Chart -> List (Html.Attribute msg) -> Html msg
apexChart aChart extraAttributes =
    Html.node "apex-chart"
        ((Html.Attributes.property "data" <|
            encodeChart aChart
         )
            :: extraAttributes
        )
        []
