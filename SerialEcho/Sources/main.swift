import SwiftIO
import MadBoard

let uart = UART(Id.UART0)

var messgae = [UInt8](repeating: 0, count: 100)

print("Start UART echo test")

while true {
    let count = uart.checkBufferReceived()

    if count > 0 {
        for i in messgae.indices {
            messgae[i] = 0   
        }

        uart.read(into: &messgae, count: count)
        uart.write(Array(messgae[0..<count]))

    }
    sleep(ms: 10)
}