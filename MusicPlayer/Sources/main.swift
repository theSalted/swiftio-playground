
import SwiftIO
import MadBoard


let speaker = I2S(Id.I2S0, rate: 16_000)

let player = Player(speaker, sampleRate: 16_000)

player.bpm = Mario.bpm
player.timeSignature = Mario.timeSignature



while true {
    player.playTracks(Mario.tracks, waveforms: Mario.trackWaveforms, amplitudeRatios: Mario.amplitudeRatios)
    sleep(ms: 1000)
}
