module Apex.RoundChart exposing (toApex)

import Apex.ChartDefinition exposing (ApexChart, Series(..), defaultChart, defaultChartOptions)
import Charts.RoundChart exposing (RoundChart, RoundChartType(..))


toApex : RoundChart -> ApexChart
toApex chart =
    let
        { name, series, chartOptions } =
            Charts.RoundChart.chartData chart

        ( labels, values ) =
            List.unzip series
    in
    { defaultChart
        | chart = { defaultChartOptions | type_ = toApexChartType chartOptions.type_ }
        , series =
            SingleValueSeries values
        , labels = Just labels
    }


toApexChartType : RoundChartType -> Apex.ChartDefinition.ChartType
toApexChartType type_ =
    case type_ of
        Pie ->
            Apex.ChartDefinition.Pie

        Radial ->
            Apex.ChartDefinition.RadialBar
