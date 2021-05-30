module Charts.RoundChart exposing
    ( RoundChart
    , pieChart
    , radialBar
    , chartData
    , RoundChartType(..)
    )

{-| Use this module to create pie charts, radial charts (and all kind of roundly shaped charts).
These charts generally work with either 1 single value or a single series of values


# Building a chart

@docs RoundChart


## Start

@docs pieChart
@docs radialBar


## Customizations

To be implemented


# Internals

@docs chartData
@docs RoundChartType

-}


{-| Internal representation of the chart type
-}
type RoundChartType
    = Pie
    | Radial


type alias RoundChartOptions =
    { type_ : RoundChartType }


defaultChartOptions : RoundChartOptions
defaultChartOptions =
    { type_ = Pie }


type alias RoundChartData =
    { name : String
    , series : List ( String, Float )
    , chartOptions : RoundChartOptions
    }


{-| The opaque type representing RoundCharts
-}
type RoundChart
    = RoundChart RoundChartData


{-| Internal accessor to the round chart definition

this is used to translate from RoundChart to ApexChart

-}
chartData : RoundChart -> RoundChartData
chartData (RoundChart data) =
    data


{-| Creates a pie chart with the given title and series
-}
pieChart : String -> List ( String, Float ) -> RoundChart
pieChart name series =
    RoundChart
        { name = name
        , series = series
        , chartOptions = { defaultChartOptions | type_ = Pie }
        }


{-| Create a radial bar chart with the given title and series

Note for a simple "gauge"-type chart, simply give a single-item list as series.

-}
radialBar : String -> List ( String, Float ) -> RoundChart
radialBar name series =
    RoundChart
        { name = name
        , series = series
        , chartOptions = { defaultChartOptions | type_ = Radial }
        }
