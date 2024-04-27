import SwiftIO
import MadBoard

let led = DigitalOut(Id.D18)

let sSignal = [false, false, false]
let oSignal = [true, true, true]

func send(_ values: [Bool], to light: DigitalOut) {
    let long = 1000
    let short = 500

    for value in values {
        light.high()
        if value {
            sleep(ms: long)
        } else {
            sleep(ms: short)
        }
        light.low()
        sleep(ms: short)
    }
}

while true {
    send(sSignal, to: led)
    send(oSignal, to: led)
    send(sSignal, to: led)
    sleep(ms: 1000)
}