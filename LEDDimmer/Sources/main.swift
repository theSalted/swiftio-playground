import SwiftIO
import MadBoard

let pot = AnalogIn(Id.A0)
let led = PWMOut(Id.PWM4A)

while true {
    let dutyCycle = pot.readPercentage()
    led.setDutycycle(dutyCycle)

    sleep(ms: 20)
}