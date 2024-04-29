import SwiftIO
import MadBoard

let pot = AnalogIn(Id.A0)

while true {
    let potVoltage = pot.readVoltage()
    print("Potentiometer voltage: \(potVoltage)")
    sleep(ms: 1000)
}