module Apex.RoundChart exposing (toApex)

import Apex.ChartDefinition exposing (ApexChart, defaultChart)
import Charts.RoundCharts exposing (RoundChart)


toApex : RoundChart -> ApexChart
toApex chart =
    let
        { series, chartOptions } =
            Charts.RoundCharts.chartData chart

        ( labels, values ) =
            List.unzip series
    in
    { defaultChart
        | chart = { defaultChartOptions | type_ = toApexChartType chartOptions.type_ }
        , series = [ SingleValue values ]
        , labels = Just labels
    }


toApexChartType : RoundChartType -> Apex.ChartDefinition.ChartType
toApexChartType type_ =
    case type_ of
        Pie ->
            Apex.ChartDefinition.Pie

        Radial ->
            Apex.ChartDefinition.RadialBar
