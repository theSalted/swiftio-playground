import SwiftIO
import MadBoard
import ESP32ATClient

let rst = DigitalOut(Id.D24, value: true)
let espUart = UART(Id.UART1, baudRate: 115200)

let esp = ESP32ATClient(uart: espUart, rst: rst)


let uart = UART(Id.UART0)

var ssid: String = ""
var password: String = ""
var isWifiMode = false

while true {
    UpdateUART { cmd in
        if cmd == "join wifi" {
            WriteUART("Input the SSID:")
            isWifiMode = true
            return
        }
        
        if isWifiMode {
            if ssid == "" {
                ssid = cmd
                WriteUART("Input the password:")
                return
            }

            if password == "" {
                password = cmd
                try? JoiningWiFi(ssid: ssid, password: password)
                isWifiMode = false
                return
            }
        }

        WriteUART("Unknown command")
    }
    sleep(ms: 10)
}

func UpdateUART(callback: (String) -> Void) {
    let count = uart.checkBufferReceived()

    if count > 0 {
        var buffer = [UInt8](repeating: 100, count: count)
        uart.read(into: &buffer)

        let str = String(decoding: buffer, as: UTF8.self)
        callback(str)
    }
}

func WriteUART(_ str: String) {
    let buffer = [UInt8]((str + "\n").utf8)
    uart.write(buffer)
}

func JoiningWiFi(ssid: String, password: String) throws {
    try esp.reset()
    WriteUART("ESP32 status: \(esp.esp32Status)")

    var wifiMode = try esp.getWiFiMode()
    _ = try esp.setWiFiMode(wifiMode)

    wifiMode = try esp.getWiFiMode()
    WriteUART("ESP32 WiFi mode: \(wifiMode)")

    try esp.joinAP(ssid: ssid, password: password, timeout: 20000)
}
