import SwiftIO
import MadBoard

let led = DigitalOut(Id.D18)
let button = DigitalIn(Id.D1)

while true {
    // let buttonPressed = button.read()

    // if buttonPressed == true {
    //     led.write(true)
    // } else {
    //     led.write(false)
    // }
    
    led.write(button.read())
    sleep(ms: 10)
}