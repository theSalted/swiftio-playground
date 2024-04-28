import SwiftIO
import MadBoard

let led = DigitalOut(Id.D18)
let button = DigitalIn(Id.D1)

var buttonPressed = false

while true {
    let buttonPressing = button.read()
    if !buttonPressing && buttonPressed {
        led.toggle()
    }
    buttonPressed = buttonPressing
    sleep(ms: 10)
}