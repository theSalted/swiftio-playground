import SwiftIO
import MadBoard

let button = DigitalIn(Id.D1)
let led = DigitalOut(Id.D18)

func togggleLed() {
    led.toggle()
}

button.setInterrupt(.rising, callback: togggleLed)

while true {
    sleep(ms: 1000)
}