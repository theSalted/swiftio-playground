import SwiftIO
import MadBoard
import LIS3DH

let i2c = I2C(Id.I2C0)
let dice = LIS3DH(i2c)

let indicator = DigitalOut(Id.D18)

var steadyCount = 999

while true {
    let diceValue = dice.readXYZ()
    
    if abs(diceValue.x) > 0.3 || abs(diceValue.y) > 0.3 {
        indicator.high()
        steadyCount = 0
    } else {
        steadyCount += 1
        if steadyCount == 50 {
            indicator.low()
            print(Int.random(in: 1...6))
        }
    }

    sleep(ms: 5)
}