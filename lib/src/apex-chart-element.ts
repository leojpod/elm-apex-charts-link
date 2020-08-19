import "apexcharts";
export class ApexChartElement extends HTMLElement {
  private chart: ApexCharts;
  private _data: { series: any };
  constructor() {
    super();
    this.chart = null;
    this.data = null;
  }
  connectedCallback() {
    console.log("connection -> ", this._data);
    const options = {
      series: this._data.series,
      noData: {
        text: "loading",
      },
      chart: {
        // height: 350,
        width: "100%",
        type: "line",
        toolbar: { show: false },
        zoom: { enabled: false },
      },
      dataLabels: {
        enabled: false,
      },
      stroke: {
        curve: "smooth",
      },
      xaxis: {
        type: "datetime",
      },
      grid: {
        show: false,
        padding: { left: 0, right: 0, top: 0 },
      },
      legend: {
        show: false,
      },
    };
    const chartElement = document.createElement("div");
    this.appendChild(chartElement);
    this.chart = new ApexCharts(chartElement, options);
    this.chart.render();
  }
  static get observedAttributes() {
    return ["data"];
  }
  public get data(): { series: ApexAxisChartSeries | ApexNonAxisChartSeries } {
    return this._data;
  }
  public set data(value) {
    this.setAttribute("data", JSON.encode(value));
  }

  attributeChangedCallback(
    _name: any,
    _oldValue: any,
    newValue: { series: ApexAxisChartSeries | ApexNonAxisChartSeries }
  ) {
    this.data = newValue;
    console.log("you call me I call you");
    this.chart.updateSeries(this.data.series);
    this.chart.render();
  }

  disconnectCallback() {}
}
