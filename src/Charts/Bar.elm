module Charts.Bar exposing
    ( Bar
    , bar
    , addSeries
    , chartData
    , isHorizontal
    )

{-| Use this module to build histograms with discrete scales or bar diagrams.


# Building a chart

@docs Bar


## Start

@docs bar


## Adding data

@docs addSeries


# Internals

@docs chartData

-}


{-| This is an internal type to make sure we're keeping the definitions and list handling coherent and free from outside manipulation
-}
type Bar
    = BarChart BarChartData


type alias BarChartData =
    { series : List Series
    , plotOptions : BarChartOptions
    }


defaultBarChartData : BarChartData
defaultBarChartData =
    { series = []
    , plotOptions = defaultBarChartOptions
    }


type alias Series =
    { name : String
    , data : List Float
    }


type alias BarChartOptions =
    { isHorizontal : Bool }


defaultBarChartOptions : BarChartOptions
defaultBarChartOptions =
    { isHorizontal = False }


{-| This is the entry point to create a bar chart.

It creates an empty chart which you can use as basis, adding series to it, tuning axis and such...

-}
bar : Bar
bar =
    BarChart defaultBarChartData


{-| internal method to grab the internal plot reprensentation

this is use to transform the underlying reprensentation to an Apex chart definition

-}
chartData : Bar -> BarChartData
chartData (BarChart data) =
    data


{-| use this function to add series to your bar chart.

NOTE: it won't work well if your series have different length!
(in a later release we might want to do something about that)

-}
addSeries : String -> List Float -> Bar -> Bar
addSeries name dataPoints (BarChart data) =
    BarChart
        { data
            | series = { name = name, data = dataPoints } :: data.series
        }



{--
# Customizations
--}


{-| by default, bar charts are vertical but it is nice to get them horizontal sometimes
-}
isHorizontal : Bar -> Bar
isHorizontal (BarChart ({ plotOptions } as data)) =
    BarChart
        { data
            | plotOptions =
                { plotOptions
                    | isHorizontal = True
                }
        }
