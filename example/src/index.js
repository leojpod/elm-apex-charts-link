import { Elm } from './Main.elm'
// this is a parcel issue it seems (https://github.com/apexcharts/apexcharts.js/issues/1393)
//   |
//   V
import ApexCharts from 'apexcharts/dist/apexcharts.common'
import '@webcomponents/custom-elements'

const app = Elm.Main.init({ node: document.getElementById('my-app') })

// APEX CHART ZONE
app.ports.updateChart.subscribe((data) => {
  const options = {
    series: data.series,
    noData: {
      text: 'loading'
    },
    chart: {
    // height: 350,
      width: '100%',
      type: 'line',
      toolbar: { show: false },
      zoom: { enabled: false }
    },
    dataLabels: {
      enabled: false
    },
    stroke: {
      curve: 'smooth'
    },
    xaxis: {
      type: 'datetime'
    },
    grid: {
      show: false,
      padding: { left: 0, right: 0, top: 0 }
    },
    legend: {
      show: false
    }
  }
  const chart = new ApexCharts(document.querySelector('#chart1'), options)
  chart.render()
})

class ApexChart extends HTMLElement {
  connectedCallback () {
    console.log('connection -> ', this.data)
    const options = {
      series: this.data.series,
      noData: {
        text: 'loading'
      },
      chart: {
        // height: 350,
        width: '100%',
        type: 'line',
        toolbar: { show: false },
        zoom: { enabled: false }
      },
      dataLabels: {
        enabled: false
      },
      stroke: {
        curve: 'smooth'
      },
      xaxis: {
        type: 'datetime'
      },
      grid: {
        show: false,
        padding: { left: 0, right: 0, top: 0 }
      },
      legend: {
        show: false
      }
    }
    const chartElement = document.createElement('div')
    this.appendChild(chartElement)
    this.chart = new ApexCharts(chartElement, options)
    this.chart.render()
  }

  attributeChangedCallback () {
    console.log('you call me I call you')
    this.chart.updateSeries(this.data.series)
  }

  disconnectCallback () {}
}
customElements.define('apex-chart', ApexChart)
