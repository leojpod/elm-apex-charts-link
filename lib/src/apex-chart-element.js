import '@webcomponents/custom-elements'
import ApexCharts from 'apexcharts/dist/apexcharts.common'

export class ApexChartElement extends HTMLElement {
  constructor () {
    super()
    this.chart = null
  }

  connectedCallback () {
    const data = this.data
    console.log('connectedCallback data -> ', data)
    console.log('data series -> ', data?.series)
    const options = {
      series: data?.series || [],
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

  // to avoid useless encoding - decoding we'll use props to move things around
  // this means that to detect changes we'll transform the prop into a function via the setter
  set data (newValue) {
    console.log('you call me I call you')
    if (this.chart) {
      this.chart.updateSeries(newValue.series)
    }
  }

  disconnectCallback () {}
}
customElements.define('apex-chart', ApexChartElement)
