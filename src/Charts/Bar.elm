module Charts.Bar exposing
    ( Bar
    , bar
    , addSeries
    , chartData
    , isHorizontal, isStacked
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

import Dict exposing (Dict)
import Maybe.Extra as Maybe


{-| This is an internal type to make sure we're keeping the definitions and list handling coherent and free from outside manipulation
-}
type Bar
    = BarChart BarChartData


type alias BarChartData =
    { series : Series
    , labels : List String
    , plotOptions : BarChartOptions
    }


defaultBarChartData : BarChartData
defaultBarChartData =
    { series = Dict.empty
    , labels = []
    , plotOptions = defaultBarChartOptions
    }


type alias Series =
    Dict String (List Float)


type alias BarChartOptions =
    { isHorizontal : Bool
    , isStacked : Bool
    }


defaultBarChartOptions : BarChartOptions
defaultBarChartOptions =
    { isHorizontal = False
    , isStacked = False
    }


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
addSeries : String -> List ( String, Float ) -> Bar -> Bar
addSeries name dataPoints (BarChart data) =
    let
        numberOfSeries =
            data.series
                |> Dict.toList
                |> List.unzip
                |> Tuple.second
                |> List.head
                |> Maybe.unwrap 0 List.length
    in
    BarChart
        { data
            | labels = name :: data.labels
            , series =
                dataPoints
                    |> List.foldl
                        (\( label, value ) ->
                            Dict.update label
                                (\maybeValues ->
                                    Just <|
                                        case maybeValues of
                                            Nothing ->
                                                value :: List.repeat numberOfSeries 0

                                            Just values ->
                                                value :: values
                                )
                        )
                        data.series
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


{-| by default, bar charts are not stacked but you can fix this easily
-}
isStacked : Bar -> Bar
isStacked (BarChart ({ plotOptions } as data)) =
    BarChart
        { data
            | plotOptions = { plotOptions | isStacked = True }
        }
