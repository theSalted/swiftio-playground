import SwiftIO
import MadBoard

let red = DigitalOut(Id.RED, value: true)
let green = DigitalOut(Id.GREEN, value: true)
let blue = DigitalOut(Id.BLUE, value: true)

while true {
    // Red
    setRGB(true, false, false)
    // Green
    setRGB(false, true, false)
    // Blue
    setRGB(false, false, true)
    // Yellow
    setRGB(true, true, false)
    // Manganta
    setRGB(true, false, true)
    // Cyan
    setRGB(false, true, true)
    // White
    setRGB(true, true, true)
    // Off
    setRGB(false, false, false)
}

func setRGB(_ redOn: Bool, _ greenOn: Bool, _ blueOn: Bool)  {
    red.write(!redOn)
    green.write(!greenOn)
    blue.write(!blueOn)
    sleep(ms: 1000)
}