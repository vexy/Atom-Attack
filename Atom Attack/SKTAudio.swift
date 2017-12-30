import AVFoundation

private let SKTAudioInstance = SKTAudio()

public class SKTAudio {
    public var soundEffectPlayer: AVAudioPlayer?

    public class func shared() -> SKTAudio {
        return SKTAudioInstance
    }

    public func playSoundEffect(_ filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }

        var error: NSError? = nil
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url!)
        } catch let error1 as NSError {
            error = error1
            soundEffectPlayer = nil
        }
        if let player = soundEffectPlayer {
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
}
