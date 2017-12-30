//
//  SKTAudio.swift
//  Atom Attack
//
//  Created by Vladislav Jevremović on 12/30/17.
//  Copyright © 2015 Vladislav Jevremovic. All rights reserved.
//

import AVFoundation

public class SKTAudio {

    private var soundEffectPlayer: AVAudioPlayer?

    public static let shared: SKTAudio = SKTAudio()

    public func playSoundEffect(_ filename: String) {
        if let url = Bundle.main.url(forResource: filename, withExtension: nil) {
            do {
                soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            } catch let error as NSError {
                print("Could not create audio player: \(error)")
                soundEffectPlayer = nil
            }
            if let player = soundEffectPlayer {
                player.numberOfLoops = 0
                player.prepareToPlay()
                player.play()
            }
        } else {
            print("Could not find file: \(filename)")
            return
        }
    }
}
