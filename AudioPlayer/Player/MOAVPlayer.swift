//
//  MOAVPlayer.swift
//  AudioPlayer
//
//  Created by owen on 01/04/2018.
//  Copyright © 2018 owen. All rights reserved.
//
/// MOAVPlayer.swift
/// 功能：将使用AVKit、AVPlayer、AVFoundation放在一个文件内处理
/// 1、
/// 2、
///
/// 问题：
/// 1、
///


import UIKit
import AVKit


class MOAVPlayer: NSObject {
    
    // MARK: Properties
    
    var asset: AVAsset!
    var playItem: AVPlayerItem!
    var player: AVPlayer!
    
    // Type property（Swift的Singleton写法）
    static let sharedMOAVPlayer = MOAVPlayer()
    
    
    // MARK: Methods
    
    // play
    func play() {
        if let player = player {
            player.play()
        }
    }
    
    // pause
    func pause() {
        if let player = player {
            player.pause()
        }
    }
    
    // stop
//    func stop() {
//        if let player = player {
//            // AVPlayer没有stop方法
//        }
//    }
    
    // 创建AVPlayer实例
    func player(withUrl url: URL) {
        player = AVPlayer(url: url)
    }
    
    //
    func player(withChapter chapter: Chapter, xPath: String, attribute: String) {
        var mediaUrl:URL!
        let mediaUrlString = Helper.parseHTML(withUrl: URL.init(string: chapter.urlString)!, xPath: xPath, attribute: attribute)
        print("mediaUrlString: \(String(describing: mediaUrlString))")
        if let mediaUrlString = mediaUrlString {
            mediaUrl = URL.init(string: mediaUrlString)!
        }
        self.player(withUrl: mediaUrl)
    }
    
    //
    func player(withChapter chapter: Chapter) {
        let xPath = "//*[@id=\"down\"]"
        let attribute = "href"
        var mediaUrl:URL!
        let mediaUrlString = Helper.parseHTML(withUrl: URL.init(string: chapter.urlString)!, xPath: xPath, attribute: attribute)
        print("mediaUrlString: \(String(describing: mediaUrlString))")
        if let mediaUrlString = mediaUrlString {
            mediaUrl = URL.init(string: mediaUrlString)!
        }
        self.player(withUrl: mediaUrl)
    }

}






