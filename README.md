# Apex link

![CI](https://github.com/leojpod/elm-apex-charts-link/workflows/CI/badge.svg?branch=main)

`elm-apex-charts-link`: _a tentative solution to using apex charts within the comfort of elm_

## Design decisions

### the targeted solution

I wanted to get an easy way to "describe" how the charts should look like and defer the transformation from the "graph description" to the actual Apex JSON to a custom encoder.

Right now, the code looks a bit like this.
First make define a plot/bar chart/etc with one of the appropriate function:

```elm
plot =
    Plot.plot
        |> Plot.addLineSeries "Connections by week" (connectionsByWeek logins)
        |> Plot.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
        |> Plot.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
        |> Plot.withXAxisType Plot.DateTime
```

Then, transform that definition into an apex chart and customize the appearance:

```elm
apexPlot =
    plot
        |> Apex.fromPlotChart
        |> Apex.withColors [ "#ff2E9B", "#3f51b5", "#7700D0" ]
```

It is still pretty much just a WIP and needs to support more options and more types of charts.
Hopefully, this will come in a near future but it is already working fine as it is.

### How to plug it

Once we've got a nice chart description what shall we do with it?
This package offers 2 ways of plugging your data to an actual chart: via ports or via a custom-elements.

The first options is achieve by providing a JSON encoder for the charts (see [`Apex.encodeChart`](Apex#encodeChart)).

The second requires to import and setup the npm companion package: [elm-apex-charts-link](https://www.npmjs.com/package/elm-apex-charts-link), once you've set it up you can use the [`Apex.apexChart`](Apex#apexChart).

For a complete example, have a look at [`/example`](https://github.com/leojpod/elm-apex-charts-link/tree/master/example).

## ApexCharts' custom element

The second part of this elm-package is actually language/framework agnostic.
It is a custom element wrapping the apexcharts library as simply as possible.

To use it, install and import the npm package `apexcharts-custom-element` and voilà. You should now be able to create a custom-element named `apex-chart` which will take the apexcharts definition in the `chartData` property.
If your framework/environment does not allow you to work easily with properties, you can instead use the attribute `data-chart` (with JSON encoding) which will work just the same.
