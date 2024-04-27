import SwiftIO
import MadBoard

let led = DigitalOut(Id.D18)

while true {
    led.write(true)
    sleep(ms: 500)

    led.write(false)
    sleep(ms: 500)
}
