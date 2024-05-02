import SwiftIO
import MadBoard
import PCF8563

let i2c = I2C(Id.I2C0)
let rtc = PCF8563(i2c)

let daysOfWeek = [
    "Monday", "Tuesday", "Wednesday", "Thursdat", "Friday", "Saturday", "Sunday"
]

let currentTime = PCF8563.Time(
    year: 2023, 
    month: 5,
    day: 2,
    hour: 3, 
    minute: 50, 
    second: 0, 
    dayOfWeek: 3
)

rtc.setTime(currentTime)

while true {
    let time = rtc.readTime()
    print(formatDateTime(time))
    sleep(ms: 1000)
}

func formatNum(_ number: UInt8) -> String {
    return number < 10 ? "0\(number)" : "\(number)"
}

func formatDateTime(_ time: PCF8563.Time) -> String {
    var string = ""
    string += "\(time.year)" + "/" + formatNum(time.month) + "/" + formatNum(time.day)
    string += " " + daysOfWeek[Int(time.dayOfWeek)] + " "
    string += formatNum(time.hour) + ":" + formatNum(time.minute) + ":" + formatNum(time.second)
    return string
}