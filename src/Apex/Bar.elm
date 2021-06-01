module Apex.Bar exposing (toApex)

import Apex.ChartDefinition as ChartDefinition exposing (ApexChart, Series(..), defaultChart, defaultChartOptions)
import Charts.Bar exposing (Bar)


toApex : Bar -> ApexChart
toApex chart =
    let
        { series, plotOptions } =
            Charts.Bar.chartData chart

        { isHorizontal } =
            plotOptions
    in
    { defaultChart
        | chart =
            { defaultChartOptions
                | type_ =
                    ChartDefinition.Bar { isHorizontal = isHorizontal }
            }
        , series =
            series
                |> List.map
                    (\{ name, data } ->
                        { name = name
                        , data = data
                        }
                    )
                |> MultiValuesSeries
    }
