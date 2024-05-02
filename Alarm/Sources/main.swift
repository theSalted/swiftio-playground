import SwiftIO
import MadBoard
import PCF8563

let i2c = I2C(Id.I2C0)
let rtc = PCF8563(i2c)

let led = DigitalOut(Id.D18)
let buzzer = PWMOut(Id.PWM5A)

let stopButton = DigitalIn(Id.D1)

let alarm = AlarmTime(hour: 0, minute: 1)
let stopAlarm = getStopAlarm(alarm, after: 10)
var isAlarmed = false

while true {
    let time = rtc.readTime()
    print("Current time: \(time)")
    if isAlarmed {
        if stopAlarm.isTimeUp(time) || stopButton.read() {
            led.low()
            buzzer.suspend()
            isAlarmed = false
        }
    } else {
        if alarm.isTimeUp(time) {
            led.high()
            buzzer.set(frequency: 500, dutycycle: 0.5)
            isAlarmed = true
        }
    }

    sleep(ms: 10)
}

func getStopAlarm(_ alarm: AlarmTime, after min: Int)  -> AlarmTime {
    var stopMinute = alarm.minute + min
    var stopHour = alarm.hour

    if stopMinute >= 60 {
        stopMinute -= 60
        stopHour = stopHour == 23 ? 0 : stopHour + 1
    }

    return AlarmTime(hour: stopHour, minute: stopMinute)
}

struct AlarmTime {
    let hour: Int
    let minute: Int

    func isTimeUp(_ time: PCF8563.Time) -> Bool {
        return time.hour == hour && time.minute == minute && time.second == 0
    }
}