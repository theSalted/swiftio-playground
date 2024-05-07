import SwiftIO
import MadBoard

let uart = UART(Id.UART0)
let led = DigitalOut(Id.D18)

while true {
    let count = uart.checkBufferReceived()

    if count > 0 {
        var buffer = [UInt8](repeating: 0, count: count)
        uart.read(into: &buffer)

        let command = String(decoding: buffer, as: UTF8.self)
        print(command)

        switch command {
        case "0": led.low()
        case "1": led.high()
        default: break
        }
    }

    sleep(ms: 10)
}