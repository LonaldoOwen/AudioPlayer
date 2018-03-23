//
//  Player.swift
//  AudioPlayer
//
//  Created by owen on 17/8/13.
//  Copyright © 2017年 owen. All rights reserved.
//
/// Player
/// 功能：将AVAudioPlayer的操作放在一个class中
///
///
///


import Foundation
import AVFoundation
import MediaPlayer


protocol PlayerDelegate: NSObjectProtocol {
    
    func playerDidFinishPlaying(_ player: Player, successfully flag: Bool)
    
}

class Player: NSObject, AVAudioPlayerDelegate {
    
    /// properties
    var audioPlayer: AVAudioPlayer?
    var delegate: PlayerDelegate?
    
    /// methods
    
    // 播放
    func playerPlay() {
        // play
        if let player = audioPlayer {
            player.play()
        }
    }
    // 暂停
    func playerPause() {
        // pause
        if let player = audioPlayer {
            player.pause()
        }
    }
    // 停止
    func playerStop() {
        // stop
        if let player = audioPlayer {
            player.stop()
        }
    }
    
    // 播放audio实例
    func playAudio(_ model: AudioModel) {
        
        audioPlayer?.delegate = nil
        audioPlayer?.stop()
        let path = Bundle.main.path(forResource: model.audioName, ofType: model.audioType)
        let url = URL(fileURLWithPath: path!)
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch let error {
            print("audioPlayer error: \(error.localizedDescription)")
        }
        // 设置锁屏显示歌曲信息（包括锁屏和控制中心）
        let infoDic = [MPMediaItemPropertyTitle: model.audioName,
                       MPMediaItemPropertyArtist: model.musician,
                       MPMediaItemPropertyPlaybackDuration: self.audioPlayer!.duration] as [String : Any]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = infoDic
    }

    
    /// AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("//Player: audioPlayerDidFinishPlaying")
        self.delegate?.playerDidFinishPlaying(self, successfully: flag)
    }

    deinit {
        print("//Player: deinit")
        audioPlayer?.delegate = nil
    }
}

