import SwiftIO
import MadBoard

let led = PWMOut(Id.PWM4A)

let maxDutyCycle: Float = 1.0 
let minDutyCycle: Float = 0.0

let stepDutycyle: Float = 0.1

var dutycycle: Float = 0.0

let downButton = DigitalIn(Id.D1)
let upButton = DigitalIn(Id.D19)

var dutycycleChanged = false

downButton.setInterrupt(.rising) {
    dutycycle -= stepDutycyle
    dutycycle = max(dutycycle, minDutyCycle)
    dutycycleChanged = true
}

upButton.setInterrupt(.rising) {
    dutycycle += stepDutycyle
    dutycycle = min(dutycycle, maxDutyCycle)
    dutycycleChanged = true
}

while true {
    if dutycycleChanged {
        led.setDutycycle(dutycycle)
        dutycycleChanged = false
    }
    sleep(ms: 10)
}