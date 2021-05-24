module Charts.RoundCharts exposing (..)


type alias RoundChartData = 
  {
    name : String
    , series: List (String, Float)
  }

type RoundChart = RoundChart RoundChartData

