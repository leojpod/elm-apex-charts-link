import '@webcomponents/custom-elements'
import ApexCharts from 'apexcharts/dist/apexcharts.common'

export class ApexChartElement extends HTMLElement {
  constructor () {
    super()
    this._chart = null
    this._data = null
  }

  connectedCallback () {
    // first  check if the property is set
    let data = this._data
    if (!data) {
      // if the property is not set, use the attribute: 'data-chart'
      data = JSON.parse(this.getAttribute('data-chart'))
      console.log('ApexChartElement data-chart attribute? ', data)
    }
    this.createChart(data)
  }

  createChart (data) {
    // clear up the space first
    while (this.firstChild) {
      this.removeChild(this.firstChild)
    }
    // create the chart element holder
    const chartElement = document.createElement('div')
    // add it
    this.appendChild(chartElement)
    // create the chart in the holder
    this._chart = new ApexCharts(chartElement, data)
    // render it
    this._chart.render()
  }

  set chartData (newValue) {
    this._data = newValue
    if (this._chart) {
      this._chart.updateSeries(newValue.series)
    } else {
      this.createChart(newValue)
    }
  }

  get chartData () {
    return this._data
  }

  disconnectCallback () {}
}

customElements.define('apex-chart', ApexChartElement)
