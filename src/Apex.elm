module Apex exposing (encodeChart)


import Json.Encode

type XAxis =
  Timestamp
  | Date
  | Numeric
  | Custom 

type ChartDefinition data = 
  Debug.todo "yooohooooooooooo"

encodeChart : ChartDefinition data -> serieOr -> Json.Encode.Value
encodeChart _ _ =
    Debug.todo "not implemented yet"
