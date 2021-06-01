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
    , MultiSeries
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
    | Bar BarOptions
    | Pie (PieOptions {})
    | Donut
    | RadialBar (RadialBarOptions {})


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


type alias MultiSeries =
    { name : String
    , data : List Float
    }


type Series
    = SingleValueSeries (List Float)
    | MultiValuesSeries (List MultiSeries)
    | PairedValuesSeries (List PairedSeries)


type alias Point =
    { x : Float
    , y : Float
    }


type SeriesType
    = LineSeries
    | ColumnSeries


type alias BarOptions =
    { isHorizontal : Bool }


type alias PieOptions a =
    AnglesOptions a


type alias RadialBarOptions a =
    AnglesOptions a


type alias AnglesOptions a =
    { a
        | angles :
            Maybe
                { from : Int
                , to : Int
                }
    }


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
    , series = PairedValuesSeries []
    }


defaultChartOptions : ChartOptions
defaultChartOptions =
    { toolbar = False
    , type_ = Area
    , zoom = False
    }


defaultLegendOptions : LegendOptions
defaultLegendOptions =
    False


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
