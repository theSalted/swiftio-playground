import SwiftIO
import MadBoard

let startButton = DigitalIn(Id.D1)
let player = DigitalIn(Id.D19)
let buzzer = PWMOut(Id.PWM5A)
let led = DigitalOut(Id.D18)

while true {
    if startButton.read() {
        buzzer.set(frequency: 500, dutycycle: 0.5)
        sleep(ms: 500)
        buzzer.suspend()
        sleep(ms: 1000 * Int.random(in: 1...5))
        led.high()
        let startClockCycle = getClockCycle()
        while !player.read() {
            sleep(ms: 1)
        }
        let duration = cyclesToNanoseconds(start: startClockCycle, stop: getClockCycle())
        led.low()
        print("Reflex time: \(Float(duration) / 1000_1000) ms")
    }

    sleep(ms: 10)
}