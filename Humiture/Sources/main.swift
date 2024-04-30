import SwiftIO
import MadBoard
import SHT3x

let i2c = I2C(Id.I2C0)
let humiture = SHT3x(i2c)

while true {
    let temp = humiture.readCelsius()
    let humidity = humiture.readHumidity()
    print("Tenmprature: \(temp)C")
    print("Humidity: \(humidity)%")
    sleep(ms: 1000)
}