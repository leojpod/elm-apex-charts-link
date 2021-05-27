module Charts.Plots exposing
    ( PlotChart
    , Point
    , XAxisType(..)
    , addColumnSeries
    , addLineSeries
    , plot
    , withXAxisType
    )

{-| A simple record type to make things a bit clearer when writing series
-}


type alias Point =
    { x : Float
    , y : Float
    }


type SeriesType
    = Lines
    | Columns


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


type alias XAxisOptions =
    XAxisType


type alias GridOptions =
    Bool


defaultGridOptions : GridOptions
defaultGridOptions =
    False


type alias PlotOptions =
    { type_ : Maybe String
    , xAxis : XAxisOptions
    , grid : GridOptions
    }


defaultPlotOptions : PlotOptions
defaultPlotOptions =
    { type_ = Nothing
    , xAxis = defaultXAxisType
    , grid = defaultGridOptions
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
type PlotChart
    = PlotChart PlotChartData


mapPlotOption : (PlotOptions -> PlotOptions) -> PlotChart -> PlotChart
mapPlotOption fct (PlotChart data) =
    PlotChart { data | plotOptions = fct data.plotOptions }


plot : PlotChart
plot =
    PlotChart defaultData



{--
# Data series

--}


{-| as the name suggest, this add a line to your chart by creating a series with the given name and by linking the given points together.
-}
addLineSeries : String -> List Point -> PlotChart -> PlotChart
addLineSeries name newSeries (PlotChart data) =
    PlotChart
        { data
            | series =
                { name = name
                , type_ = Lines
                , data = newSeries
                }
                    :: data.series
        }


{-| as the name suggest, this add a new column series to your chart using the given name and by adding a bar for each of the given points.
-}
addColumnSeries : String -> List Point -> PlotChart -> PlotChart
addColumnSeries name newSeries (PlotChart data) =
    PlotChart
        { data
            | series =
                { name = name
                , type_ = Columns
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
withXAxisType : XAxisType -> PlotChart -> PlotChart
withXAxisType type_ =
    mapPlotOption (\options -> { options | xAxis = type_ })
