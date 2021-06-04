module Apex.Options exposing (withColors)

import Apex.ChartDefinition exposing (ApexChart)


withColors : List String -> ApexChart -> ApexChart
withColors colors chart =
    { chart | colors = colors }
