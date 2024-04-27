import SwiftIO
import MadBoard

let redLed = DigitalOut(Id.D18)

let blueLed = DigitalOut(Id.BLUE)

let timer = Timer(period: 1500)

func ToggleLedSwitch() {
    redLed.toggle()
}

timer.setInterrupt(ToggleLedSwitch)

while true {
    blueLed.high()
    sleep(ms: 500)

    blueLed.low()
    sleep(ms: 500)
}
