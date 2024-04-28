import SwiftIO 
import MadBoard

let button0 = DigitalIn(Id.D1)
let button1 = DigitalIn(Id.D19)
let led = DigitalOut(Id.D18)


//  OG: OnPress 

// var ledToggled = false

// while true {
//     if !ledToggled && (button0.read() || button1.read()) {
//         led.toggle()
//         ledToggled = true
//     }

//     if !button0.read() && !button1.read() {
//         ledToggled = false
//     }

//     sleep(ms: 10)
// }


//  Exercise: OnRelease

var buttonsPressed = false

while true {
    let buttonsPressing = button0.read() || button1.read()

    if !buttonsPressing && buttonsPressed {       
        led.toggle()
    }

    buttonsPressed = buttonsPressing

    sleep(ms: 10)
}