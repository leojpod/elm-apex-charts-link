import { Elm } from './Main.elm'
// this is a parcel issue it seems (https://github.com/apexcharts/apexcharts.js/issues/1393)
//   |
//   V
import ApexCharts from 'apexcharts/dist/apexcharts.common'

import './main.css'
import '@webcomponents/custom-elements'
import '../../src/apex-chart-element'

const app = Elm.Main.init({ node: document.getElementById('my-app') })

// APEX CHART ZONE
app.ports.updateChart.subscribe((chartDescription) => {
  const chart = new ApexCharts(
    document.querySelector('#chart1'),
    chartDescription
  )
  chart.render()
})
