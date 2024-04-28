import SwiftIO
import MadBoard

let led = PWMOut(Id.PWM4A)

let maxDutycycle: Float = 1.0
let minDutycycle: Float = 0.0

// Set the change of duty cycle for each action
let stepDutycycle: Float = 0.01

var dutycycle: Float = minDutycycle

var upDirection = true

while true {
    led.setDutycycle(dutycycle)
    sleep(ms: 100)

    if upDirection {
        dutycycle += stepDutycycle
        if dutycycle >= maxDutycycle {
            upDirection = false
            dutycycle = maxDutycycle
        }
    } else {
        dutycycle -= stepDutycycle
        if dutycycle <= minDutycycle {
            upDirection = true
            dutycycle = minDutycycle
        }
    }
}