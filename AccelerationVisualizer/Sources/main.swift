import SwiftIO
import MadBoard
import LIS3DH
import ST7789

let bl = DigitalOut(Id.D2)
let rst = DigitalOut(Id.D12)
let dc = DigitalOut(Id.D13)
let cs = DigitalOut(Id.D5)
let spi = SPI(Id.SPI0, speed: 30_000_000)

let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

let i2c = I2C(Id.I2C0)
let accelerometer = LIS3DH(i2c)

let red: UInt16 = 0x07E0
let green: UInt16 = 0x001F
let blue: UInt16 = 0xF800

let gRange: Int
switch accelerometer.getRange() {
case .g2: gRange = 4
case .g4: gRange = 8
case .g8: gRange = 16
case .g16: gRange = 32
}

let barWidth = 200
let barHeight = 40
let spacer = 20
let startY = (screen.height - barHeight * 3 - spacer * 2) / 2

var xBar = Bar(y: startY, width: barWidth, height: barHeight, color: red, screen: screen)
var yBar = Bar(y: startY + barHeight + spacer, width: barWidth, height: barHeight, color: green, screen: screen)
var zBar = Bar(y: startY + (barHeight + spacer) * 2, width: barWidth, height: barHeight, color: blue, screen: screen)

while true {
    let values = accelerometer.readXYZ()
    xBar.update(values.x, gRange: gRange)
    yBar.update(values.y, gRange: gRange)
    zBar.update(values.z, gRange: gRange)
    sleep(ms: 10)
}