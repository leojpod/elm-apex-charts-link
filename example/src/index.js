let app = Elm.Main.init({ node: document.getElementById('my-app') })

app.ports.updateChart.subscribe((data) => 
                              console.log('data -> ', data))

