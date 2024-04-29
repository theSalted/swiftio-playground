import SwiftIO
import MadBoard

let pot = AnalogIn(Id.A0)
let buzzer = PWMOut(Id.PWM5A)

while true {
    let potPercentage = pot.readPercentage()

    let frequency = 0 + Int(1000 * potPercentage)
    buzzer.set(frequency: frequency, dutycycle: 0.5)
    sleep(ms: 20)
}