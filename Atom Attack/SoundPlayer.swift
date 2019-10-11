//
//  SKTAudio.swift
//  Atom Attack
//
//  Created by Vladislav Jevremović on 12/30/17.
//  Copyright © 2015 Vladislav Jevremovic. All rights reserved.
//
import AVFoundation

public enum SoundEffects: String {
    case coreHit  = "Contact.mp3"
    case gameOver = "Explosion.mp3"
}

public class SoundPlayer {
    class func play(soundEffect: SoundEffects) {
        guard let resourceURL = Bundle.main.url(forResource: soundEffect.rawValue, withExtension: nil) else {
            fatalError("Unable to open sound file")
        }
        
        DispatchQueue.main.async {
            //initialize the player and play the sound
            guard let audioPlayer = try? AVAudioPlayer(contentsOf: resourceURL) else { return } //do not fatalError in order not to interrupt the game if it's only the player who's failing
            
            audioPlayer.numberOfLoops = 1
            audioPlayer.volume = 1
            
            DispatchQueue.main.async {
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }
        }
    }
}
