module Apex.Plot exposing (toApex)

import Apex.ChartDefinition as ChartDefinition exposing (ApexChart, Series(..), defaultChart, defaultChartOptions)
import Charts.Plot exposing (Plot, SeriesType(..), XAxisOptions, XAxisType(..))


toApex : Plot -> ApexChart
toApex chart =
    let
        { series, plotOptions } =
            Charts.Plot.chartData chart

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
                                        ChartDefinition.Bar { isHorizontal = False }
                            )
                        |> Maybe.withDefault ChartDefinition.Line
            }
        , xAxis = Just <| toXAxisApexOptions xAxis
        , series =
            series
                |> List.map
                    (\{ name, type_, data } ->
                        { name = name
                        , type_ = toApexSerieType type_
                        , data = data
                        }
                    )
                |> PairedValuesSeries
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
