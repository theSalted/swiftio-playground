import SwiftIO
import MadBoard
import ESP32ATClient
import ExtrasJSON

let rst = DigitalOut(Id.D24, value: true)
let espUart = UART(Id.UART1, baudRate: 115200)

let esp = ESP32ATClient(uart: espUart, rst: rst)


let uart = UART(Id.UART0)

var ssid: String = ""
var password: String = ""

var openWeatherAPIKey: String = ""
var cityName: String = ""

var switcher: SwitchBoard = .exchange

while true {
    processUARTInput { input in
        
        switch switcher {
        case .exchange:
            processExchangeInput(input)
        case .wifi:
            processWifiInput(input)
        case .weather:
            processWeatherInput(input)
        }
    }
    sleep(ms: 10)
}

func processExchangeInput(_ input: String) {
    guard let command = Command(rawValue: input) else {
        writeUART("Unknown command")
        return
    }

    switch command {
    case .joinWiFi:
        ssid = ""
        password = ""
        writeUART("Input the SSID:")
        switcher = .wifi
    case .getWeather:
        openWeatherAPIKey = ""
        cityName = ""
        guard esp.wifiStatus == .ready else {
            writeUART("Please join the WiFi first. Wifi Status: \(esp.wifiStatus)")
            switcher = .exchange
            return
        }
        writeUART("Input Open Weather API key:")
        switcher = .weather
    }
}

func processWeatherInput(_ input: String) {
    if openWeatherAPIKey.isEmpty {
        openWeatherAPIKey = input
        writeUART("Input the city name:")
    } else {
        cityName = input
        getWeatherInfo()
        switcher = .exchange
    }
}

func getWeatherInfo() {
    guard esp.wifiStatus == .ready else {
        writeUART("Please join the WiFi first. Wifi Status: \(esp.wifiStatus)")
        switcher = .exchange
        return
    }
    do {
        let response = try esp.httpGet(url: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(openWeatherAPIKey)", timeout: 30000)

        let weatherInfo = try XJSONDecoder().decode(WeatherInfo.self, from: Array(response.utf8))
        writeUART("City: \(weatherInfo.cityName)")
        writeUART("Weather: \(weatherInfo.weatherConditions[0].main)")
        writeUART("Temp: \(weatherInfo.mainInfo.temp)")
        writeUART("Humidity: \(weatherInfo.mainInfo.humidity)")
    } catch let error as DecodingError {
        writeUART("JSON Decoding Error: \(error)")
    } catch {
        writeUART("Http GET Error: \(error)")
    }
}


func processWifiInput(_ input: String) {
    if ssid.isEmpty {
        ssid = input
        writeUART("Input the password:")
    } else {
        password = input
        do {
            try joiningWiFi(ssid: ssid, password: password)
        } catch {
            writeUART("Failed to join the WiFi, detail: \(error)")
        }
        switcher = .exchange
    }
}

func processUARTInput(callback: (String) -> Void) {
    let count = uart.checkBufferReceived()

    if count > 0 {
        var buffer = [UInt8](repeating: 100, count: count)
        uart.read(into: &buffer)

        let str = String(decoding: buffer, as: UTF8.self)
        callback(str)
    }
}

func writeUART(_ str: String) {
    let buffer = [UInt8]((str + "\r\n").utf8)
    uart.write(buffer)
}

func joiningWiFi(ssid: String, password: String) throws {
    try esp.reset()
    writeUART("ESP32 status: \(esp.esp32Status)")

    var wifiMode = ESP32ATClient.WiFiMode.station
    _ = try esp.setWiFiMode(wifiMode)

    wifiMode = try esp.getWiFiMode()
    writeUART("ESP32 WiFi mode: \(wifiMode)")

    try esp.joinAP(ssid: ssid, password: password, timeout: 20000)
    writeUART("ESP32 WiFi status: \(esp.wifiStatus)")

    let ipInfo = try esp.getStationIP()
    writeUART(ipInfo.joined(separator: "\r\n"))
}

enum Command: String {
    case joinWiFi = "join wifi"
    case getWeather = "get weather"
}

enum SwitchBoard {
    case exchange
    case wifi
    case weather
}