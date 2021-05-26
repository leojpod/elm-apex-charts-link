module Charts.RoundCharts exposing
    ( RoundChart
    , chartData
    , pieChart
    , radialBar
    )



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


type RoundChart
    = RoundChart RoundChartData


chartData : RoundChart -> RoundChartData
chartData (RoundChart data) =
    data


pieChart : String -> List ( String, Float ) -> RoundChart
pieChart name series =
    RoundChart
        { name = name
        , series = series
        , chartOptions = { defaultChartOptions | type_ = Pie }
        , options = Charts.Options.default
        }


radialBar : String -> List ( String, Float ) -> RoundChart
radialBar name series =
    RoundChart
        { name = name
        , series = series
        , chartOptions = { defaultChartOptions | type_ = Radial }
        , options = Charts.Options.default
        }
