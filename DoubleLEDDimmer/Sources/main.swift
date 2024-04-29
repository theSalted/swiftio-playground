import SwiftIO
import MadBoard

let brightnessPot = AnalogIn(Id.A0)
let intensityPot = AnalogIn(Id.A11)
let led = PWMOut(Id.PWM4A)

let minIntensity: Float = 0.2
let maxIntensity: Float = 1

while true {
    let maxDutycycle = intensityPot.readPercentage() * (maxIntensity - minIntensity) + minIntensity
    let dutycycleRatio = brightnessPot.readPercentage()
    led.setDutycycle(dutycycleRatio * maxDutycycle)
    sleep(ms: 20)
}