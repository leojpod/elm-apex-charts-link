# Apex link

*a tentative solution to using apex charts within the comfort of elm*

## Design decisions

### the targeted solution

I wanted to get an easy way to "describe" how the charts should look like and defer the transformation from the "graph description" to the actual Apex JSON to a custom encoder.

At the moment the code looks like this: 

```elm
Apex.chart
    |> Apex.addLineSeries "Connections by week" (connectionsByWeek logins)
    |> Apex.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
    |> Apex.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
    |> Apex.withXAxisType Apex.DateTime

```

It it still pretty much just a WIP and needs to support more options and more types of charts to be more complete.
However it is working fine already as it is.


### How to plug it

Once we've got a nice chart description what shall we do with it? 
This package offers 2 ways of plugging your data to an actual chart: via ports or via a custom-elements.

The first options is achieve by providing a JSON encoder for the charts (see [`Apex.encodeChart`](Apex#encodeChart)).

The second requires to import and setup the npm companion package: [put the url here](), once you've set it up you can use the [`Apex.apexChart`](Apex#apexChart).

For a complete example, have a look at [`/example`](https://github.com/leojpod/elm-apex-charts-link/tree/master/example).
