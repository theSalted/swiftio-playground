import SwiftIO
import MadBoard

let brightnessPot = AnalogIn(Id.A0)
let blinkRatePot = AnalogIn(Id.A11)
let led = PWMOut(Id.PWM4A)

while true {
    let blinkTime = blinkRatePot.readRawValue()
    led.setDutycycle(brightnessPot.readPercentage())
    sleep(ms: blinkTime)
    led.suspend()
    sleep(ms: blinkTime)
}