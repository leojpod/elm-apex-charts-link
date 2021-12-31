import '@webcomponents/custom-elements'
import ApexCharts from 'apexcharts/dist/apexcharts.common'

export class ApexChartElement extends HTMLElement {
  constructor () {
    super()
    this._chart = null
    this._data = null
  }

  connectedCallback () {
    const data = this._data
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

  // to avoid useless encoding - decoding we'll use props to move things around
  // this means that to detect changes we'll transform the prop into a function via the setter
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

  /**
   * override this function is you need something a bit more fancy like custom formatter and the like
   **/
  static optionTransformer (options) {
    return options
  }

  disconnectCallback () {}
}

customElements.define('apex-chart', ApexChartElement)
