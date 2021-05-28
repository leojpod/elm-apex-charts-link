module Apex.ChartDefinition exposing
    ( ApexChart
    , ChartOptions
    , ChartType(..)
    , CurveType(..)
    , DataLabelOptions
    , GridOptions
    , LegendOptions
    , NoDataOptions
    , PairedSeries
    , Point
    , Series(..)
    , SeriesType(..)
    , StrokeOptions
    , XAxisOptions
    , XAxisType(..)
    , defaultChart
    , defaultChartOptions
    )

{-|

    The intent of that file is to get a "transition type" that will allow for more straight forward encoding to JSON and decoupling the Apex representation from the Chart definition

-}


type alias ApexChart =
    { chart : ChartOptions
    , legend : LegendOptions
    , noData : NoDataOptions
    , dataLabels : DataLabelOptions
    , labels : Maybe (List String)
    , stroke : StrokeOptions
    , grid : GridOptions
    , xAxis : Maybe XAxisOptions
    , series : Series
    }


type alias ChartOptions =
    { toolbar : Bool
    , type_ : ChartType
    , zoom : Bool
    }


type ChartType
    = Line
    | Area
    | Bar
    | Pie
    | Donut
    | RadialBar


type alias LegendOptions =
    Bool


type alias NoDataOptions =
    String


type alias DataLabelOptions =
    Bool


type alias StrokeOptions =
    { curve : CurveType
    , show : Bool
    , width : Int
    }


type CurveType
    = Smooth
    | Strait
    | Stepline


type alias GridOptions =
    Bool


type alias XAxisOptions =
    XAxisType


type XAxisType
    = Category
    | DateTime
    | Numeric


type alias PairedSeries =
    { data : List Point
    , name : String
    , type_ : SeriesType
    }


type Series
    = SingleValueSeries (List Float)
    | PairedValueSeries (List PairedSeries)


type alias Point =
    { x : Float
    , y : Float
    }


type SeriesType
    = LineSeries
    | ColumnSeries


defaultChart : ApexChart
defaultChart =
    { chart = defaultChartOptions
    , legend = defaultLegendOptions
    , noData = defaultNoDataOptions
    , dataLabels = defaultDataLabelOptions
    , labels = Nothing
    , stroke = defaultStrokeOptions
    , grid = defaultGridOptions
    , xAxis = Nothing
    , series = PairedValueSeries []
    }


defaultChartOptions : ChartOptions
defaultChartOptions =
    { toolbar = False
    , type_ = Area
    , zoom = False
    }


defaultLegendOptions : LegendOptions
defaultLegendOptions =
    True


defaultNoDataOptions : NoDataOptions
defaultNoDataOptions =
    "loading ..."


defaultDataLabelOptions : DataLabelOptions
defaultDataLabelOptions =
    False


defaultStrokeOptions : StrokeOptions
defaultStrokeOptions =
    { curve = Smooth
    , show = True
    , width = 2
    }


defaultGridOptions : GridOptions
defaultGridOptions =
    False
