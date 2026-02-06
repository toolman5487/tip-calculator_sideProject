//
//  AudioPlayerService.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/4/1.
//

import Foundation
import AVFoundation

protocol AudioPlayerService{
    func playSound()
}

final class DefaultAudioPlayerService: AudioPlayerService{
    
    private var player: AVAudioPlayer?
    
    func playSound(){
        let path = Bundle.main.path(forResource: "click", ofType: "m4a")
        let url = URL(fileURLWithPath: path!)
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
    
}
