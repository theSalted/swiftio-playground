import SwiftIO
import MadBoard 

let buzzer = PWMOut(Id.PWM5A)
let pot = AnalogIn(Id.A0)

let frequencies = [262, 294, 330, 349, 392, 440, 494, 523]
var lastFrequencyIndex = frequencies.count

while true {
    let frequencyIndex = Int((Float(pot.readRawValue() * (frequencies.count - 1)) / Float(pot.maxRawValue)).rounded(.toNearestOrAwayFromZero))

    if frequencyIndex != lastFrequencyIndex {
        buzzer.set(frequency: frequencies[frequencyIndex], dutycycle: 0.5)
        sleep(ms: 500)
        buzzer.suspend()
        lastFrequencyIndex = frequencyIndex
    }

    sleep(ms: 10)
}