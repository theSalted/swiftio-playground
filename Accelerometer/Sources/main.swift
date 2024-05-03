import SwiftIO
import MadBoard
import LIS3DH

let i2c = I2C(Id.I2C0)
let accelerometer = LIS3DH(i2c)

while true {
    let accelerations = accelerometer.readXYZ()
    print("x: \(accelerations.x)g")
    print("y: \(accelerations.y)g")
    print("z: \(accelerations.z)g")
    print("\n")
    sleep(ms: 1000)
}