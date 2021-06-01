module Apex.Bar exposing (toApex)

import Apex.ChartDefinition as ChartDefinition exposing (ApexChart, Series(..), defaultChart, defaultChartOptions)
import Charts.Bar exposing (Bar)
import Dict exposing (Dict)


toApex : Bar -> ApexChart
toApex chart =
    let
        { series, labels, plotOptions } =
            Charts.Bar.chartData chart

        { isHorizontal, isStacked } =
            plotOptions
    in
    { defaultChart
        | chart =
            { defaultChartOptions
                | type_ =
                    ChartDefinition.Bar { isHorizontal = isHorizontal, isStacked = isStacked }
            }
        , labels = Just labels
        , series =
            series
                |> Dict.toList
                |> List.map
                    (\( name, data ) ->
                        { name = name
                        , data = data
                        }
                    )
                |> MultiValuesSeries
    }
