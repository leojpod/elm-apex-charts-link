module Apex.PlotChart exposing (toApex)

import Apex.ChartDefinition as ChartDefinition exposing (ApexChart, SeriesData(..), defaultChart, defaultChartOptions)
import Charts.PlotChart exposing (PlotChart, SeriesType(..), XAxisOptions, XAxisType(..))


toApex : PlotChart -> ApexChart
toApex chart =
    let
        { series, plotOptions } =
            Charts.PlotChart.chartData chart

        { xAxis } =
            plotOptions
    in
    { defaultChart
        | chart =
            { defaultChartOptions
                | type_ =
                    series
                        |> List.head
                        |> Maybe.map .type_
                        |> Maybe.map
                            (\type_ ->
                                case type_ of
                                    LineSeries ->
                                        ChartDefinition.Line

                                    ColumnSeries ->
                                        ChartDefinition.Bar
                            )
                        |> Maybe.withDefault ChartDefinition.Line
            }
        , xAxis = Just <| toXAxisApexOptions xAxis
        , series =
            series
                |> List.map
                    (\{ name, type_, data } ->
                        { name = Just name
                        , type_ = Just <| toApexSerieType type_
                        , data = ChartDefinition.PairedValue data
                        }
                    )
    }


toXAxisApexOptions : XAxisOptions -> ChartDefinition.XAxisOptions
toXAxisApexOptions type_ =
    case type_ of
        Category ->
            ChartDefinition.Category

        DateTime ->
            ChartDefinition.DateTime

        Numeric ->
            ChartDefinition.Numeric


toApexSerieType : SeriesType -> ChartDefinition.SeriesType
toApexSerieType type_ =
    case type_ of
        LineSeries ->
            ChartDefinition.LineSeries

        ColumnSeries ->
            ChartDefinition.ColumnSeries
