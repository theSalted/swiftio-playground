import SwiftIO
import MadBoard

let led = PWMOut(Id.PWM4A)
let button = DigitalIn(Id.D1)

let maxDutycycle: Float = 1.0
let minDutycycle: Float = 0.0

var dutyCycle: Float = minDutycycle
var stepDutyCycle: Float = 0.01

let loopDuration = 10 
let blinkPeriod = 1000
var blinkTime = 0

var patternIndex = 0
var changePattern  = false

resetDutyCycle()

var buttonPressed = false

button.setInterrupt(.falling)  {
    buttonPressed = true
}

while true {
    if changePattern {
        resetDutyCycle()
        changePattern = false
    } else {
        updateDutyCycle()
    }

    led.setDutycycle(dutyCycle)
    sleep(ms: loopDuration)

    if buttonPressed {
        changePattern = true
        patternIndex += 1
        if patternIndex == LEDPattern.allCases.count {
            patternIndex = 0
        }

        buttonPressed = false
    }
}


func resetDutyCycle() {
    switch LEDPattern(rawValue: patternIndex)! { 
    case .off:
        dutyCycle = minDutycycle
    case .on:
        dutyCycle = maxDutycycle
    case .blink:
        dutyCycle = maxDutycycle
        blinkTime = 0
    case .breathing:
        dutyCycle = minDutycycle
        stepDutyCycle = abs(stepDutyCycle)
    }
}

func updateDutyCycle() {
    switch LEDPattern(rawValue: patternIndex)! {
    case .blink:
        blinkTime += loopDuration
        dutyCycle = blinkTime % blinkPeriod < (blinkPeriod / 2) ? maxDutycycle : minDutycycle
    case .breathing:
        dutyCycle += stepDutyCycle
        if stepDutyCycle > 0 && dutyCycle >= maxDutycycle {
            stepDutyCycle.negate()
            dutyCycle = maxDutycycle
        } else if stepDutyCycle < 0 && dutyCycle <= minDutycycle {
            stepDutyCycle.negate()
            dutyCycle = minDutycycle
        }
    default: break
    }
}
enum LEDPattern: Int, CaseIterable {
    case off
    case on 
    case blink
    case breathing
}