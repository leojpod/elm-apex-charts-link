import '@webcomponents/custom-elements'
import ApexCharts from 'apexcharts/dist/apexcharts.common'

export class ApexChartElement extends HTMLElement {
  constructor () {
    super()
    this.chart = null
    this._data = null
  }

  connectedCallback () {
    const data = this.data
    const chartElement = document.createElement('div')
    this.appendChild(chartElement)
    this.chart = new ApexCharts(chartElement, data)
    this.chart.render()
  }

  // to avoid useless encoding - decoding we'll use props to move things around
  // this means that to detect changes we'll transform the prop into a function via the setter
  set data (newValue) {
    // console.log('newValue -> ', newValue)
    this._data = newValue
    if (this.chart) {
      this.chart.updateSeries(newValue.series)
    }
  }

  get data () {
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
