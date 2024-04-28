import SwiftIO
import MadBoard

let buzzer = PWMOut(Id.PWM5A)

let frequencies = [262, 294, 330, 349, 392, 440, 494, 523]

for frequency in frequencies {
    buzzer.set(frequency: frequency, dutycycle: 0.5)
    sleep(ms: 500)
}

buzzer.suspend()

while true {
    sleep(ms: 1000)
}