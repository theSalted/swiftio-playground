import SwiftIO
import MadBoard
import LIS3DH

let i2c = I2C(Id.I2C0)
let accelerometer = LIS3DH(i2c)

let led = DigitalOut(Id.D18)
let buzzer = PWMOut(Id.PWM5A)

let resetButton = DigitalIn(Id.D1)

let timer = Timer(period: 30_000)

var password = [Direction](repeating: .left, count: 3)
updatePassword()

var passwordIndex = 0

var reset = false
var start = false

timer.setInterrupt(start: false) {
    reset = true
}

print("Tilt/move your board to start.")

while true {
    if passwordIndex < password.count {
        if let direction = getDirection(accelerometer.readXYZ())  {
            if !start {
            timer.start()
            start = true
        }
            if direction == password[passwordIndex]  {
                passwordIndex += 1
                print("Correct!")
                beep(500)
            } else {
                passwordIndex = 0
                print("Wrong! Restart from the first one...")
            }
        }
    } else if passwordIndex == password.count {
        led.high()
        print("Unlocked!")
        timer.stop()
        passwordIndex += 1
    }

    if resetButton.read() {
        reset = true
    }

    if reset {
        updatePassword()
        timer.stop()

        passwordIndex = 0
        start = false
        reset = false

        led.low()
        beep(1000)

        print("Timeout ot reset button is pressed. Password is reset. Tilt/move your board to restart.")
    }
    sleep(ms: 20)
}

func beep(_ frequency: Int) {
    buzzer.set(frequency: frequency, dutycycle: 0.5)
    sleep(ms: 300)
    buzzer.suspend()
}

func updatePassword() {
    for i in 0..<password.count {
        password[i] = Direction(rawValue: .random(in: 0..<4))!
    }
}

func getDirection(_ values: (x: Float, y: Float, z: Float)) -> Direction? {
    if values.x > 0.5 {
        return .left
    } else if values.x < -0.5 {
        return .right
    }

    if values.y > 0.5 {
        return .backward
    } else if values.y < -0.5 {
        return .forward
    }

    return nil
}

enum Direction: Int {
    case left
    case right
    case forward
    case backward
}