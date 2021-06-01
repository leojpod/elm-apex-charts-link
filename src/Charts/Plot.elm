module Charts.Plot exposing
    ( Plot
    , plot
    , addColumnSeries
    , addLineSeries
    , Point
    , withXAxisType
    , XAxisType(..)
    , SeriesType(..)
    , chartData
    , XAxisOptions
    )

{-| Use this module to create historgrams, bar charts, scatter plots, line plots, area plots and the like (basically anything that does not come in a round-like shape).


# Building a chart

@docs Plot


## Start

You should start by creating an empty chart with:

@docs plot


## Adding data

Once you have your plot/chart, you can start adding data to it.
At the moment this is done with `addColumnSeries` and `addLineSeries`

@docs addColumnSeries
@docs addLineSeries

These make use of a simple record that describe data point

@docs Point


## Customizations

NOTE: this part is still heavy a work in progress.

@docs withXAxisType
@docs XAxisType


# Internals

These are stuff you should never have to care about

@docs SeriesType
@docs chartData
@docs XAxisOptions

-}


{-| A simple record type to make things a bit clearer when writing series
-}
type alias Point =
    { x : Float
    , y : Float
    }


{-| internal type to track the type of series present in the chart.

_Do not use this type without a really good reason._

-}
type SeriesType
    = LineSeries
    | ColumnSeries


type alias SeriesData =
    List Point


type alias Series =
    { name : String
    , type_ : SeriesType
    , data : SeriesData
    }



{-
   # Options to put in one day:

     - annotations
     - grid
     - axis and axis format
-}


{-| Describe how the x-axis of your graph should be labelled.

It can be either a Category, a DateTime or a Numeric value

NOTE: for the DateTime to properly work I suggest that the x-values in your series should be turned into miliseconds via `Time.posixToMillis`. I hope to find something better in due time but that's the best option until then.

-}
type XAxisType
    = Category
    | DateTime
    | Numeric


defaultXAxisType : XAxisType
defaultXAxisType =
    Numeric


{-| internal type that represent all the possible options that can be supported by the chart library

_Do not use this type without a really good reason._

-}
type alias XAxisOptions =
    XAxisType


type alias GridOptions =
    Bool


defaultGridOptions : GridOptions
defaultGridOptions =
    False


type alias PlotOptions =
    { xAxis : XAxisOptions
    , horizontal : Bool
    }


defaultPlotOptions : PlotOptions
defaultPlotOptions =
    { xAxis = defaultXAxisType
    , horizontal = False
    }


type alias PlotChartData =
    { series : List Series
    , plotOptions : PlotOptions
    }


defaultData : PlotChartData
defaultData =
    { series = []
    , plotOptions = defaultPlotOptions
    }


{-| This is an internal type to make sure we're keeping the definitions and list handling coherent and free from outside manipulation
-}
type Plot
    = PlotChart PlotChartData


{-| internal method to grab the internal plot reprensentation

this is use to transform the underlying reprensentation to an Apex chart definition

-}
chartData : Plot -> PlotChartData
chartData (PlotChart data) =
    data


mapPlotOption : (PlotOptions -> PlotOptions) -> Plot -> Plot
mapPlotOption fct (PlotChart data) =
    PlotChart { data | plotOptions = fct data.plotOptions }


{-| This is the entry point to create a plot chart.

It creates an empty chart which you can use as basis, adding series to it, tuning axis and such...

-}
plot : Plot
plot =
    PlotChart defaultData



{--
# Data series

--}


{-| as the name suggest, this add a line to your chart by creating a series with the given name and by linking the given points together.
-}
addLineSeries : String -> List Point -> Plot -> Plot
addLineSeries name newSeries (PlotChart data) =
    PlotChart
        { data
            | series =
                { name = name
                , type_ = LineSeries
                , data = newSeries
                }
                    :: data.series
        }


{-| as the name suggest, this add a new column series to your chart using the given name and by adding a bar for each of the given points.
-}
addColumnSeries : String -> List Point -> Plot -> Plot
addColumnSeries name newSeries (PlotChart data) =
    PlotChart
        { data
            | series =
                { name = name
                , type_ = ColumnSeries
                , data = newSeries
                }
                    :: data.series
        }



{--
# Plot Options

any option that relates to the regular plots
--}


{-| change the type of x-axis used in you graph
-}
withXAxisType : XAxisType -> Plot -> Plot
withXAxisType type_ =
    mapPlotOption (\options -> { options | xAxis = type_ })
