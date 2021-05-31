module Charts.Bar exposing ()


{-| Use this module to build histograms with discrete scales or bar diagrams.

# Building a chart

@docs Bar

## Start

@docs bar
-}


type Bar = 
    BarChart BarChartData

type alias BarChartData = 
    {

    }

defaultBarChartData : BarChartData
defaultBarChartData = {}

bar: Bar
bar = 
    BarChart defaultBarChartData
