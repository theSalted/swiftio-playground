import ST7789

struct Bar {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    let screen: ST7789
    let color: UInt16

    var indicatorPos: Int?
    let indicatorColor: UInt16 = 0xFFFF

    init(y: Int, width: Int, height: Int, color: UInt16, screen: ST7789) {
        self.y = y
        self.width = width
        self.height = height
        self.color = color
        self.screen = screen
        x = (screen.width - width) / 2

        let data = [UInt16](repeating: color, count: width * height)
        data.withUnsafeBytes {
            screen.writeBitmap(x: x, y: y, width: width, height: height, data: $0)
        }
    }

    mutating func update(_ accel: Float, gRange: Int) {
        let currentPos = x + Int((accel + 2) * Float((width - 1) / gRange))

        if indicatorPos != currentPos {
            for py in y..<y+height {
                screen.writePixel(x: currentPos, y: py, color: indicatorColor)
            }

            if let indicatorPos {
                for py in y..<y+height {
                    screen.writePixel(x: indicatorPos, y: py, color: color)
                }
            }

            indicatorPos = currentPos
        }
    }
}