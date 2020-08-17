# Apex link

*an tentative solution to using apex charts within the comfort of elm*

## Design decisions

### the targeted solution

I would like to find something that allows to write things piece by piece.
A bit like what `Json.Decode.Extra` provides. 

The code could look a bit like: 

```elm
baseChart 
  |> withLegends -- here goes the legend configuration options
  |> addSeries -- here goes the definitions for a scatter plot with lines
  |> addSeries -- here goes the definitions for an histogram to be placed behind the line series
  |> Apex.encodeChart
```

An idea would be to offer different entry points: `lineChart`, `radar`, ... Which yields a parametrised version of  a type `Chart serieType` which will in turns parametrised the `withLegends`, `withSomething` and `addSeries` functions.

Another thing that would be good is to have helper to transform data into series but that's something for later


### How to plug it

Once we've got a nicely encoded JSON what shall you do with it? 
This package should offer/offers 2 ways of plugging your data to a chart: via ports or via custom-elements.
