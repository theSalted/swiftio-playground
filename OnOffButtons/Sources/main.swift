import SwiftIO
import MadBoard


let onButton = DigitalIn(Id.D1)
let offButton = DigitalIn(Id.D19)
let led = DigitalOut(Id.D18)

var ledOn = false

var onButtonPressed = false
var offButtonPressed = false

while true {
    if ledOn {
        if offButton.read() {
            offButtonPressed = true
        }

        if offButtonPressed && offButton.read() {
            led.low()
            offButtonPressed = false
            ledOn = false
        }
    } else {
        if onButton.read() {
            onButtonPressed = true
        }

        if onButtonPressed && !onButton.read() {
            led.high()
            onButtonPressed = false
            ledOn = true
        }
    }

    sleep(ms: 100)
}