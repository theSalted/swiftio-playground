import SwiftIO

public class Player {
    public typealias NoteInfo = (note: Note, noteValue: Int)
    public typealias TimeSignature = (beatPerBar: Int, noteVaulePerBear: Int)

    public var bpm: Int = 60
    public var timeSignature: TimeSignature = (4, 4)
    public var halfStep = 0
    public var fadeDuration: Float = 0.1

    let amplitude = 16383
    var beatDuration: Float { 60.0 / Float(bpm) }

    var sampleRate: Float
    var speaker: I2S

    var buffer32 = [Int32](repeating: 0, count: 200_000)
    var buffer16 = [Int16](repeating: 0, count: 200_000)

    public init(_ speaker: I2S, sampleRate: Float) {
        self.speaker = speaker
        self.sampleRate = sampleRate
    }

    public func playTracks(
        _ tracks: [[NoteInfo]],
        waveforms: [Waveform],
        amplitudeRatios: [Float]
    ) {
        let beatCount = tracks[0].reduce(0) {
            $0 + Float(timeSignature.noteVaulePerBear) / Float($1.noteValue)
        }

        let barCount = Int(beatCount / Float(timeSignature.beatPerBar))

        for barIndex in 0..<barCount {
            getBarData(tracks, barIndex: barIndex, waveforms: waveforms, amplitudeRatios: amplitudeRatios, data: &buffer32)

            let count = Int(Float(timeSignature.beatPerBar) * beatDuration * sampleRate * 2)
            for i in 0..<count {
                buffer16[i] = Int16(buffer32[i] / Int32(tracks.count))
            }
            sendData(data: buffer16, count: count)

        }
    }

    public func playTrack(
        _ track: [NoteInfo],
        waveform: Waveform,
        amplitudeRatio: Float
    ) {
        for noteinfo in track {
            playNote(noteinfo, waveform: waveform, amplitudeRatio: amplitudeRatio)
        }
    }

    public func playNote(
        _ noteinfo: NoteInfo,
        waveform: Waveform,
        amplitudeRatio: Float
    ) {
        let duration = calculateNoteDuration(noteinfo.noteValue)

        var frequency: Float = 0

        if noteinfo.note == .rest {
            frequency = 0
        } else {
            frequency = frequencyTable[noteinfo.note.rawValue + halfStep]!
        }

        let sampleCount = Int(duration * sampleRate)

        for i in 0..<sampleCount {
            let sample = getNoteSample(
                at: i,
                frequency: frequency, 
                noteDuration: duration, 
                waveform: waveform, 
                amplitudeRatio: amplitudeRatio)

            buffer16[i * 2] = sample
            buffer16[i * 2 + 1] = sample
        }

        sendData(data: buffer16, count: sampleCount * 2)

    }
}

extension Player {
    func getBarData(
        _ tracks: [[NoteInfo]],
        barIndex: Int,
        waveforms: [Waveform],
        amplitudeRatios: [Float],
        data: inout [Int32]
    ) {
        for i in data.indices {
            data[i] = 0
        }

        for trackIndex in tracks.indices {
            let track = tracks[trackIndex]
            let noteIndices = getNotesInBar(at: barIndex, in: track)
            var start = 0

            for index in noteIndices {
                getNoteData(
                    track[index],
                    startIndex: start,
                    waveform: waveforms[trackIndex],
                    amplitudeRatio: amplitudeRatios[trackIndex],
                    data: &data)

                start += Int(calculateNoteDuration(track[index].noteValue) * sampleRate * 2)
            }
        }
    }

    func getNoteData(
        _ noteInfo: NoteInfo,
        startIndex: Int,
        waveform: Waveform,
        amplitudeRatio: Float,
        data: inout [Int32]
    ) {
        guard noteInfo.noteValue > 0 else { return }

        let duration = calculateNoteDuration(noteInfo.noteValue)

        var frequency: Float = 0
        if noteInfo.note == .rest {
            frequency = 0
        } else {
            frequency = frequencyTable[noteInfo.note.rawValue + halfStep]!
        }

        for i in 0..<Int(duration * sampleRate) {
            let sample = Int32(getNoteSample(at: i, frequency: frequency, noteDuration: duration, waveform: waveform, amplitudeRatio: amplitudeRatio))

            data[i * 2 + startIndex] += sample
            data[i * 2 + 1 + startIndex] += sample
        }
    }

    func getNotesInBar(at barIndex: Int, in track: [NoteInfo]) -> [Int] {
        var indices: [Int] = []
        var index = 0
        var sum: Float = 0

        while Float(timeSignature.beatPerBar * (barIndex + 1)) - sum > 0.1 && index < track.count {
            sum += Float(timeSignature.noteVaulePerBear)  / Float(track[index].noteValue)

            if sum - Float(timeSignature.beatPerBar * barIndex) > 0.1 {
                indices.append(index)
            }

            index += 1
        }

        return indices
    }

    func sendData(data: [Int16], count: Int) {
        data.withUnsafeBytes { ptr in 
            let u8Array =  ptr.bindMemory(to: UInt8.self)
            speaker.write(Array(u8Array), count: count * 2)
        }
    }

    func calculateNoteDuration(_ noteValue: Int) -> Float {
        return beatDuration * (Float(timeSignature.noteVaulePerBear) / Float(noteValue))
    }

    func getNoteSample(
        at index: Int,
        frequency: Float,
        noteDuration: Float,
        waveform: Waveform,
        amplitudeRatio: Float
    ) -> Int16 {
        if frequency == 0 { return 0 }

        var sample: Float = 0

        switch waveform {
        case .square:
            sample = getSquareSample(at: index, frequency: frequency, amplitudeRatio: amplitudeRatio)
        case .triangle:
            sample = getTriangleSample(at: index, frequency: frequency, amplitudeRatio: amplitudeRatio)
        }

        let fadeInEnd = Int(fadeDuration * sampleRate)
        let fadeOutStart = Int((noteDuration - fadeDuration) * sampleRate)
        let fadeSampleCount = fadeDuration * sampleRate
        let sampleCount = Int(noteDuration * sampleRate)

        switch index {
        case 0..<fadeInEnd:
            sample *= Float(sampleCount - index) / fadeSampleCount
        case fadeOutStart..<sampleCount:
            sample *= Float(sampleCount - index)  / fadeSampleCount
        default:
            break
        }

        return Int16(sample * Float(amplitude))
    }

    func getTriangleSample(
        at index: Int,
        frequency: Float,
        amplitudeRatio: Float
    ) -> Float {
        let period = sampleRate / frequency

        let sawWave = Float(index) / period - Float(Int(Float(index) / period + 0.5))
        let triWave = 2 * abs(2 * sawWave) - 1

        return triWave * amplitudeRatio
    }

    func getSquareSample(at index: Int,
        frequency: Float,
        amplitudeRatio: Float
    ) -> Float {
        let period = Int(sampleRate / frequency)

        if index % period < period / 2 {
            return -amplitudeRatio
        } else {
            return amplitudeRatio
        }
    }
}

public enum Waveform {
    case square
    case triangle
}