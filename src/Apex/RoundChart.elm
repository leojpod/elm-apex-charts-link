module Apex.RoundChart exposing (toApex)

import Apex.ChartDefinition exposing (ApexChart, Series(..), defaultChart, defaultChartOptions)
import Charts.RoundChart exposing (RoundChart, RoundChartOptions, RoundChartType(..))


toApex : RoundChart -> ApexChart
toApex chart =
    let
        { series, chartOptions } =
            Charts.RoundChart.chartData chart

        ( labels, values ) =
            List.unzip series
    in
    { defaultChart
        | chart = { defaultChartOptions | type_ = toApexChartType chartOptions }
        , series =
            SingleValueSeries values
        , labels = Just labels
    }


toApexChartType : RoundChartOptions -> Apex.ChartDefinition.ChartType
toApexChartType { type_, angles } =
    case type_ of
        Pie ->
            Apex.ChartDefinition.Pie { angles = angles }

        Radial ->
            Apex.ChartDefinition.RadialBar { angles = angles }
