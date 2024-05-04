import SwiftIO
import MadBoard
import ST7789

let bl = DigitalOut(Id.D2)
let rst = DigitalOut(Id.D12)
let dc = DigitalOut(Id.D13)
let cs = DigitalOut(Id.D5)
let spi = SPI(Id.SPI0, speed: 30_000_000)

let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

let pot = AnalogIn(Id.A0)

let maxHieght = 200

let white: UInt16 = 0xFFFF
let black: UInt16 = 0x0000

var heightValues = [Int](repeating: 0, count: screen.width)

while true {
    let height = pot.readRawValue() * maxHieght / pot.maxRawValue

    heightValues.removeFirst()
    heightValues.append(height)

    for i in 0..<heightValues.count-1 {
        let lastHeight = heightValues[i]
        let currentHeight = heightValues[i+1]

        if lastHeight > currentHeight {
            drawLine(x: i, y: screen.height - lastHeight, height: lastHeight - currentHeight, color: black)
        } else if lastHeight < currentHeight {
            drawLine(x: i, y: screen.height - currentHeight, height: currentHeight - lastHeight, color: white)
        }
    }
    sleep(ms: 100)
}

func drawLine(x: Int, y: Int, height: Int, color: UInt16)  {
    let buffer = [UInt16](repeating: color, count: height)
    buffer.withUnsafeBytes {
        screen.writeBitmap(x: x, y: y, width: 1, height: height, data: $0)
    }
}