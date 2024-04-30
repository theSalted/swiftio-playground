import SwiftIO
import MadBoard
import SHT3x

let irc = I2C(Id.I2C0)
let humiture = SHT3x(irc)

let led = DigitalOut(Id.D18)
let button = DigitalIn(Id.D1)

var startMeasurement = false

while true {
    if button.read() {
        startMeasurement = true
    }

    if startMeasurement && !button.read() {
        led.high()
        var sum: Float = 0
        for _ in 0..<20 {
            sum += humiture.readCelsius()
            sleep(ms: 3)
        }

        print("Temperature: \(sum / 20)°C")
        startMeasurement = false
        led.low()
    }

    sleep(ms: 20)
}