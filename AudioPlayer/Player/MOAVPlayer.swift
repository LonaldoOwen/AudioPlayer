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


// 定义代理协议
protocol MOAVPlayerDelegate {
    
    // HTML parse结果（succeed、failed；解析成功，才可以加载asset）
    func moavplayer(_ moavplayer: MOAVPlayer, parseHTMLResult result: Bool, urlString: String )
    // asset 状态变（loaded，UI才可以展示基本信息）
    func moavplayer(_ moavplayer: MOAVPlayer, assetDidLoaded status: AVKeyValueStatus)
    // player item 加载进度（进度条可以根据它显示UI）
    func moavplayer(_ moavplayer: MOAVPlayer, playerItemLoadedTime time: TimeInterval)
    // player item 状态（主要是readyToPlay；可以播放）
    func moavplayer(_ moavplayer: MOAVPlayer, playerItemDidReadyToPlay status: AVPlayerItemStatus)
    // 播放进度变化
    func moavplayer(_ moavplayer: MOAVPlayer, periodicTimeDidChange time: CMTime)
    
}


class MOAVPlayer: NSObject {
    
    // MARK: Properties
    
    var asset: AVAsset!
    var playItem: AVPlayerItem!
    var player: AVPlayer!
    // Key-value observing context
    private var playerItemContext = 0
    
    // Type property（Swift的Singleton写法）
    static let sharedMOAVPlayer = MOAVPlayer()
    var delegate: MOAVPlayerDelegate?
    let parseHTMLQueue = DispatchQueue(label: "com.owen.parseHTML.queeu")
    var timeObserverToken: Any?
    
    
    // MARK: Methods
    
    // play
    func play() {
        print("#MOAVPlayer: play")
        if let player = player {
            player.play()
        }
    }
    
    // pause
    func pause() {
        print("#MOAVPlayer: pause")
        if let player = player {
            player.pause()
        }
    }
    
    // 创建AVPlayer实例
    func player(withUrl url: URL) {
        if let playItem = playItem {
            print("#移除observer：AVPlayerItem.loadedTimeRanges、AVPlayerItem.status")
            playItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), context: &playerItemContext)
            playItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &playerItemContext)
        }
        if timeObserverToken != nil {
            removePeriodicTimeObserver()
        }
        
        asset = AVAsset(url: url)
        playItem = AVPlayerItem(asset: asset)
        guard playItem != nil else {
            print("#MOAVPlayer:-Create playerItem failed!")
            return
        }
        //print("#player: duration: \(playItem.duration)")
        player = AVPlayer(playerItem: playItem)
        //player = AVPlayer(url: url)
        
        /**
         监听Asset的状态
        */
        let playableKey = "playable"
        asset.loadValuesAsynchronously(forKeys: [playableKey]) {
            var error: NSError? = nil
            let status = self.asset.statusOfValue(forKey: playableKey, error: &error)
           
            switch status {
            case .loaded:
                // Sucessfully loaded. Continue processing.
                // 当status=.loaded时，才可以获取asset的信息，更新播放进度的总时长；
                print("#.loaded")
                //print("#.loaded duration: \(self.playItem.duration)")
                // invoking delegate method
                DispatchQueue.main.sync {
                    self.delegate?.moavplayer(self, assetDidLoaded: status)
                }
            case .loading:
                //
                print("#.loading")
            case .cancelled:
                // Terminate processing
                print("#.cancelled")
            case .failed:
                // Handle error
                print("#.failed")
            case .unknown:
                //
                print("#.unknown")
            }
        }
        
        // 监听palyer item 加载进度
        playItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges),
                             options: .new,
                             context: &playerItemContext)
        // 监听player item status
        playItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status),
                             options: [.old, .new],
                             context: &playerItemContext)
        // 监听播放进度
        addPeriodicTimeObserver()
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
        print("#MOAVPlayer: - 创建player")
        
        /// 处理Parse HTML这个过程应该异步进行
        /// 
        let xPath = "//*[@id=\"down\"]"
        let attribute = "href"
        var mediaUrl:URL!
        // 异步处理parse HTML
        parseHTMLQueue.async {
            print("#异步：处理parse HTML。")
            let mediaUrlString = Helper.parseHTML(withUrl: URL.init(string: chapter.urlString)!, xPath: xPath, attribute: attribute)
            DispatchQueue.main.sync {
                print("#主线程：parse HTML完毕。")
                if let mediaUrlString = mediaUrlString {
                    // invoking delegate method
                    self.delegate?.moavplayer(self, parseHTMLResult: true, urlString: mediaUrlString)
                    mediaUrl = URL.init(string: mediaUrlString)!
                }
                self.player(withUrl: mediaUrl)
            }
        }

    }
    
    // add PeriodicTimeObserver
    func addPeriodicTimeObserver() {
        print("#MOAVPlayer: addPeriodicTimeObserver:")
        
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        /**
         监听播放进度主要方法
         */
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) {
            [weak self] time in
            
            // invoking delegate method
            //print("#Pass time: \(time)")
            self?.delegate?.moavplayer(self!, periodicTimeDidChange: time)
        }
        
    }
    
    // remove PeriodicTimeObserver
    func removePeriodicTimeObserver() {
        print("#MOAVPlayer: removePeriodicTimeObserver:")
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
        }
    }
    
    
    // MARK: - KVO
    
    // 处理oberver的监听
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        /**
         监听palyer item 加载进度
        */
        let avplayerItem = object as! AVPlayerItem
        
        if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
            // 监听加载进度（AVPlayerItem.loadedTimeRanges）
            let array = avplayerItem.loadedTimeRanges
            let timeRange = array.first?.timeRangeValue
            let timeRangeStart = CMTimeGetSeconds((timeRange?.start)!)
            let timeRangeDuration = CMTimeGetSeconds((timeRange?.duration)!)
            let totalBuffer: TimeInterval = timeRangeStart + timeRangeDuration
            
            // invoking delegate method
            //print("#MOAVPlayer: - totalBuffer: \(totalBuffer)")
            self.delegate?.moavplayer(self, playerItemLoadedTime: totalBuffer)
            
        } else if keyPath == #keyPath(AVPlayerItem.status) {
            
            /**
             监听player item状态（AVPlayerItem.status）
            */
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // ivoking delegate method
            self.delegate?.moavplayer(self, playerItemDidReadyToPlay: status)
            
            // Switch over status value
            switch status {
            case .readyToPlay:
                // Player item is ready to play.
                print("#MOAVPlayer: - playItem status: readyToPlay")
            case .failed:
                // Player item failed. See error.
                print("#MOAVPlayer: - playItem status: failed")
            case .unknown:
                // Player item is not yet ready.
                print("#MOAVPlayer: - playItem status: unknown")
            }
        }
    }
    
    
    

}






