import SwiftIO
import MadBoard
import ST7789

let bl = DigitalOut(Id.D2)
let rst = DigitalOut(Id.D12)
let dc = DigitalOut(Id.D13)
let cs = DigitalOut(Id.D5)
let spi = SPI(Id.SPI0, speed: 30_000_000)

let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

let red: UInt32 = 0xFF0000
let orange: UInt32 = 0xFF7F00
let yellow: UInt32 = 0xFFFF00
let green: UInt32 = 0x00FF00
let blue: UInt32 = 0x0000FF
let indigo: UInt32 = 0x4B0082
let violet: UInt32 = 0x9400D3
let colors888 = [red, orange, yellow, green, blue, indigo, violet]
let colors565: [UInt16] = colors888.map { getRGB565BE($0) }

let scrollStep = 5
var buffer = [UInt16](repeating: 0, count: scrollStep * screen.height)

while true {
    for color in colors565 {
        for i in 1..<screen.width / scrollStep {
            buffer.indices.forEach { buffer[$0] = color }

            let x = screen.width - i * scrollStep - 1
            buffer.withUnsafeBytes {
                screen.writeBitmap(x: x, y: 0, width: scrollStep, height: screen.height, data: $0)
            }

            sleep(ms: 30)
        }
    }
}

func getRGB565BE(_ color: UInt32) -> UInt16 {
    return UInt16(((color & 0xF80000) >> 8) | ((color & 0xFC00) >> 5) | ((color & 0xF8) >> 3)).byteSwapped
}