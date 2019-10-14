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

struct SoundPlayer {
    private static var mainPlayer: AVAudioPlayer!
    
    static func play(soundEffect: SoundEffects) {
        guard let resourceURL = Bundle.main.url(forResource: soundEffect.rawValue, withExtension: nil) else {
            fatalError("Unable to open sound file")
        }

        //initialize the player and play the sound
        guard let soundPlayer = try? AVAudioPlayer(contentsOf: resourceURL) else {
            print("Unable to create sound player")
            return
        } //do not fatalError in order not to interrupt the game if it's only the player who's failing
        
        soundPlayer.numberOfLoops = 0
        soundPlayer.volume = 1
        
        soundPlayer.prepareToPlay()
        mainPlayer = soundPlayer    //copy initialized player to static reference (to increase retain count explicitly)

        DispatchQueue.main.async {
            self.mainPlayer.play()
        }
    }
}
