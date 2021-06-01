module Apex exposing
    ( fromPlotChart
    , fromRoundChart
    , fromBarChart
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

@docs fromBarChart


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

import Apex.Bar
import Apex.ChartDefinition
    exposing
        ( ApexChart
        , ChartOptions
        , ChartType(..)
        , CurveType(..)
        , DataLabelOptions
        , GridOptions
        , LegendOptions
        , MultiSeries
        , NoDataOptions
        , PairedSeries
        , Point
        , Series(..)
        , SeriesType(..)
        , StrokeOptions
        , XAxisOptions
        , XAxisType(..)
        )
import Apex.Plot
import Apex.RoundChart
import Charts.Bar exposing (Bar)
import Charts.Plot exposing (Plot)
import Charts.RoundChart exposing (RoundChart)
import Html exposing (Html)
import Html.Attributes
import Json.Encode as Encode


{-| This is an internal type to make sure we're keeping the definitions and list handling coherent and free from outside manipulation
-}
type Chart
    = Chart ApexChart


{-| One you have a nice plot chart reprensentation from [`Charts.Plot`](./Charts-Plot) you can transform it to an Apex chart by calling this function
-}
fromPlotChart : Plot -> Chart
fromPlotChart =
    Apex.Plot.toApex >> Chart


{-| One you have a nice bar chart reprensentation from [`Charts.Bar`](./Charts-Bar) you can transform it to an Apex chart by calling this function
-}
fromBarChart : Bar -> Chart
fromBarChart =
    Apex.Bar.toApex >> Chart


{-| One you have a nice pie/radial chart reprensentation from [`Charts.RoundChart`](./Charts-RoundChart) you can transform it to an Apex chart by calling this function
-}
fromRoundChart : RoundChart -> Chart
fromRoundChart =
    Apex.RoundChart.toApex >> Chart



{--_Encoding part --}


{-| this function takes a chart and turns it into JSON data that Apex Charts can understand

NOTE: if you are using the custom-element version you should not need to use this function

-}
encodeChart : Chart -> Encode.Value
encodeChart (Chart chart) =
    encodeApexChart chart


encodeApexChart : ApexChart -> Encode.Value
encodeApexChart { chart, legend, noData, dataLabels, labels, stroke, grid, xAxis, series } =
    Encode.object <|
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
                , labels |> Maybe.map (\labelsValues -> ( "labels", Encode.list Encode.string labelsValues ))
                , encodePlotOptions chart.type_ |> Maybe.map (Tuple.pair "plotOptions")
                ]


encodeLegendOptions : LegendOptions -> Encode.Value
encodeLegendOptions show =
    Encode.object [ ( "show", Encode.bool show ) ]


encodeChartOptions : ChartOptions -> Encode.Value
encodeChartOptions { type_, toolbar, zoom } =
    Encode.object
        [ ( "width", Encode.string "100%" )
        , ( "toolbar", Encode.object [ ( "show", Encode.bool toolbar ) ] )
        , ( "zoom", Encode.object [ ( "enabled", Encode.bool zoom ) ] )
        , ( "type", encodeChartType type_ )
        , ( "stacked"
          , Encode.bool <|
                case type_ of
                    Bar { isStacked } ->
                        isStacked

                    _ ->
                        False
          )
        ]


encodeChartType : ChartType -> Encode.Value
encodeChartType type_ =
    Encode.string <|
        case type_ of
            Line ->
                "line"

            Area ->
                "area"

            Bar _ ->
                "bar"

            Pie _ ->
                "pie"

            Donut ->
                "donut"

            RadialBar _ ->
                "radialBar"


encodePlotOptions : ChartType -> Maybe Encode.Value
encodePlotOptions type_ =
    case type_ of
        Line ->
            Nothing

        Area ->
            Nothing

        Bar { isHorizontal } ->
            Just <|
                Encode.object
                    [ ( "bar"
                      , Encode.object [ ( "horizontal", Encode.bool isHorizontal ) ]
                      )
                    ]

        Pie { angles } ->
            angles
                |> Maybe.map
                    (\{ from, to } ->
                        Encode.object
                            [ ( "pie"
                              , Encode.object
                                    [ ( "startAngle", Encode.int from )
                                    , ( "endAngle", Encode.int to )
                                    ]
                              )
                            ]
                    )

        Donut ->
            Nothing

        RadialBar { angles } ->
            angles
                |> Maybe.map
                    (\{ from, to } ->
                        Encode.object
                            [ ( "radialBar"
                              , Encode.object
                                    [ ( "startAngle", Encode.int from )
                                    , ( "endAngle", Encode.int to )
                                    ]
                              )
                            ]
                    )


encodeNoDataOptions : NoDataOptions -> Encode.Value
encodeNoDataOptions text =
    Encode.object [ ( "text", Encode.string text ) ]


encodeDataLabelsOptions : DataLabelOptions -> Encode.Value
encodeDataLabelsOptions dataLabelsEnabled =
    Encode.object [ ( "enabled", Encode.bool dataLabelsEnabled ) ]


encodeStrokeOptions : StrokeOptions -> Encode.Value
encodeStrokeOptions { curve, show, width } =
    Encode.object
        [ ( "curve"
          , Encode.string <|
                case curve of
                    Smooth ->
                        "smooth"

                    Strait ->
                        "strait"

                    Stepline ->
                        "stepline"
          )
        , ( "show", Encode.bool show )
        , ( "width", Encode.int width )
        ]


encodeGridOptions : GridOptions -> Encode.Value
encodeGridOptions show =
    if show then
        Encode.object []

    else
        Encode.object
            [ ( "show", Encode.bool False )
            , ( "padding"
              , Encode.object
                    [ ( "left", Encode.int 0 )
                    , ( "right", Encode.int 0 )
                    , ( "top", Encode.int 0 )
                    ]
              )
            ]


encodeSeries : Series -> Encode.Value
encodeSeries series =
    case series of
        SingleValueSeries values ->
            Encode.list Encode.float values

        MultiValuesSeries multiSeries ->
            Encode.list encodeMultiSeries multiSeries

        PairedValuesSeries pairedSeries ->
            Encode.list encodePairedSeries pairedSeries


encodeMultiSeries : MultiSeries -> Encode.Value
encodeMultiSeries { name, data } =
    Encode.object [ ( "name", Encode.string name ), ( "data", Encode.list Encode.float data ) ]


encodePairedSeries : PairedSeries -> Encode.Value
encodePairedSeries { data, name, type_ } =
    Encode.object <|
        [ ( "name", Encode.string name )
        , ( "type"
          , Encode.string <|
                case type_ of
                    LineSeries ->
                        "line"

                    ColumnSeries ->
                        "column"
          )
        , ( "data"
          , Encode.list encodePoint data
          )
        ]


encodePoint : Point -> Encode.Value
encodePoint { x, y } =
    Encode.object [ ( "x", Encode.float x ), ( "y", Encode.float y ) ]


encodeXAxisOptions : XAxisOptions -> Encode.Value
encodeXAxisOptions type_ =
    Encode.object
        [ ( "type"
          , Encode.string <|
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
apexChart : List (Html.Attribute msg) -> Chart -> Html msg
apexChart extraAttributes aChart =
    Html.node "apex-chart"
        ((Html.Attributes.property "data" <|
            encodeChart aChart
         )
            :: extraAttributes
        )
        []
