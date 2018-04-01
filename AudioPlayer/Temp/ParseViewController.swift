//
//  ParseViewController.swift
//  AudioPlayer
//
//  Created by owen on 29/03/2018.
//  Copyright © 2018 owen. All rights reserved.
//

import UIKit
import Ji
import AVKit
import AVFoundation

class ParseViewController: UIViewController {
    
    static let reuseIdentifier = "ParserVC"
    
    var book: Book!
    var chapter: Chapter!
    var mediaUrl: URL!
    
    // AVPlayer
    let url: URL = URL.init(string: "http://other.web.ra01.sycdn.kuwo.cn/resource/n3/128/17/55/3616442357.mp3")!
    var asset: AVAsset!
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    
    // Key-value observing context
    private var playerItemContext = 0
    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 验证parser获取明朝那些事er的mp3文件url
        //tempParser()
        
        // parse media file url string
//        let chapterUrlString = book.baseUrlString + chapter.index + ".html"
//        let xPath = "//*[@id=\"down\"]"
//        let attribute = "href"
//        let mediaUrlString = Helper.parseHTML(withUrl: URL.init(string: chapterUrlString)!, xPath: xPath, attribute: attribute)
//        print("mediaUrlString: \(String(describing: mediaUrlString))")
//        if let mediaUrlString = mediaUrlString {
//            mediaUrl = URL.init(string: mediaUrlString)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func handlePlaybackAction(_ sender: Any) {
        print("button clicked!")
        // 播放Apple sample
        //playAppleSample()
        
        //
        //playRemoteFileFileWithController()
        
        //
        //playLocalFileWithAsset()
        playLocalFileWithAssetUsingGlobalProperties()
        
        //
        //playRemoteWithAVPlayer()
        //playRemoteWithAVPlayerUsingGlobalProperties()
        
        // Preparing Assets for Use
        //trackAssetStatus()
        
        // Observing Playback State
        //prepareToPlay()
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over status value
            switch status {
            case .readyToPlay:
                // Player item is ready to play.
                print("playItem status: readyToPlay")
                player.play()
            case .failed:
                // Player item failed. See error.
                print("playItem status: failed")
            case .unknown:
                // Player item is not yet ready.
                print("playItem status: unknown")
            }
        }
        
    }
    
    
    // MARK: - Helper
    
    // Observing Playback State
    func prepareToPlay() {
        // Create the asset to play
        asset = AVAsset(url: url)
        
        // Create a new AVPlayerItem with the asset and an
        // array of asset keys to be automatically loaded
        playerItem = AVPlayerItem(asset: asset,
                                  automaticallyLoadedAssetKeys: requiredAssetKeys)
        
        // Register as an observer of the player item's status property
        playerItem.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.status),
                               options: [.old, .new],
                               context: &playerItemContext)
        // Associate the player item with the player
        player = AVPlayer(playerItem: playerItem)
    }
    
    // Preparing Assets for Use
    func trackAssetStatus() {
        //let remoteUrlString = "http://dops11.zgpingshu.com/%5B%E6%BC%94%E6%92%AD%EF%BC%9A%E7%8E%8B%E6%9B%B4%E6%96%B0%5D%5B%E6%98%8E%E6%9C%9D%E9%82%A3%E4%BA%9B%E4%BA%8B%E5%84%BF%5D%5B268%E5%9B%9E%5D%2832k%29/EAD86C91B4.mp3"
        let remoteUrlString = "http://other.web.ra01.sycdn.kuwo.cn/resource/n3/128/17/55/3616442357.mp3"
        guard let url = URL.init(string: remoteUrlString) else {
            return
        }
        let asset = AVAsset(url: url)
        let playableKey = "playable"
        
        // Load the "playable" property
        // 异步加载asset，default是同步
        asset.loadValuesAsynchronously(forKeys: [playableKey]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: playableKey, error: &error)
            switch status {
            case .unknown:
                //
                print("unknown status: \(status.rawValue)")
            case .loading:
                //
                print("loading status: \(status.rawValue)")
            case .failed:
                // Handle error
                print("failed status: \(status.rawValue)")
            case .cancelled:
                // Terminate processing
                print("cancelled status: \(status.rawValue)")
            case .loaded:
                // Sucessfully loaded. Continue processing.
                print("loaded status: \(status.rawValue)")
                self.playerReadyToPlay(asset)
            }
        }
        
        
    }
    
    func playerReadyToPlay(_ asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        switch player.status {
        case .readyToPlay:
            // play
            print("playerItem status readyToPlay.")
            player.play()
        case .unknown:
            // unknown
            print("playerItem status unknown.")
        case .failed:
            // failed
            print("playerItem status failed.")
        }
    }
    
    
    func playRemoteFileFileWithController() {
        //
//        let remoteUrlString = "http://dops11.zgpingshu.com/%5B%E6%BC%94%E6%92%AD%EF%BC%9A%E7%8E%8B%E6%9B%B4%E6%96%B0%5D%5B%E6%98%8E%E6%9C%9D%E9%82%A3%E4%BA%9B%E4%BA%8B%E5%84%BF%5D%5B268%E5%9B%9E%5D%2832k%29/EAD86C91B4.mp3"
//        guard let url = URL.init(string: remoteUrlString) else {
//            return
//        }
        
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        let player = AVPlayer(url: mediaUrl)
        
        // Create a new AVPlayerViewController and pass it a reference to the player.
        let controller = AVPlayerViewController()
        controller.player = player
        
        // Modally present the player and call the player's play() method when complete.
        present(controller, animated: true) {
            player.play()
        }
    }
    
    //
    func playRemoteWithAVPlayer() {
        /// 问题：无法播放，报错
        /// “Task <BAFDB64A-28C1-4AF9-AB4C-EFDE6ACF3A9E>.<2> finished with error - code: -999”
        /// 原因：可以确定不是url的问题；
        /// 解决：
        ///
        // media url
        //let remoteUrlString = "http://dops11.zgpingshu.com/%5B%E6%BC%94%E6%92%AD%EF%BC%9A%E7%8E%8B%E6%9B%B4%E6%96%B0%5D%5B%E6%98%8E%E6%9C%9D%E9%82%A3%E4%BA%9B%E4%BA%8B%E5%84%BF%5D%5B268%E5%9B%9E%5D%2832k%29/EAD86C91B4.mp3"
        let remoteUrlString = "http://other.web.ra01.sycdn.kuwo.cn/resource/n3/128/17/55/3616442357.mp3"
        guard let url = URL.init(string: remoteUrlString) else {
            return
        }
        
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        let player = AVPlayer(url: url)
        
        //
        player.play()
        print("")
    }
    
    // 只要player定义为Global，此时可以播放？？？
    // 原因：猜测：“Note: You use AVPlayer to play a single media asset at a time. ”
    func playRemoteWithAVPlayerUsingGlobalProperties() {
        player = AVPlayer(url: url)
        player.play()
        print("")
        
    }
    
    func playLocalFileWithAsset() {
        let localUrlString = "Hotel California_Eagles_Selected Works 1972-1999.mp3"
        //let remoteUrlString = "http://dops11.zgpingshu.com/%5B%E6%BC%94%E6%92%AD%EF%BC%9A%E7%8E%8B%E6%9B%B4%E6%96%B0%5D%5B%E6%98%8E%E6%9C%9D%E9%82%A3%E4%BA%9B%E4%BA%8B%E5%84%BF%5D%5B268%E5%9B%9E%5D%2832k%29/EAD86C91B4.mp3"
        guard let url = URL.init(string: localUrlString) else {
            return
        }
        //
        let asset = AVAsset(url: url)
        
        // Create an AVPlayerItem, passing it the HTTP Live Streaming URL.
        let playerItem = AVPlayerItem(asset: asset)
        
        // Create an AVPlayer, passing it the AVPlayerItem
        let player = AVPlayer(playerItem: playerItem)
        
        //
        player.play()
    }
    
    func playLocalFileWithAssetUsingGlobalProperties() {
        
//        let remoteUrlString = "http://dops11.zgpingshu.com/%5B%E6%BC%94%E6%92%AD%EF%BC%9A%E7%8E%8B%E6%9B%B4%E6%96%B0%5D%5B%E6%98%8E%E6%9C%9D%E9%82%A3%E4%BA%9B%E4%BA%8B%E5%84%BF%5D%5B268%E5%9B%9E%5D%2832k%29/EAD86C91B4.mp3"
//        guard let url = URL.init(string: localString) else {
//            return
//        }
        
        let localString = "Hotel California_Eagles_Selected Works 1972-1999.mp3"
        let path = Bundle.main.path(forResource: localString, ofType: nil)
        let url = URL.init(fileURLWithPath: path!)
        
        //
        let asset = AVAsset(url: url)
        
        // Create an AVPlayerItem, passing it the HTTP Live Streaming URL.
        let playerItem = AVPlayerItem(asset: asset)
        
        // Create an AVPlayer, passing it the AVPlayerItem
        player = AVPlayer(playerItem: playerItem)
        
        // play
        player.play()
    }
    
    //
    func playAppleSample() {
        //
        guard let url = URL.init(string: "https://devimages-cdn.apple.com/samplecode/avfoundationMedia/AVFoundationQueuePlayer_HLS2/master.m3u8") else {
            return
        }
        
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        let player = AVPlayer(url: url)
        
        // Create a new AVPlayerViewController and pass it a reference to the player.
        let controller = AVPlayerViewController()
        controller.player = player
        
        // Modally present the player and call the player's play() method when complete.
        present(controller, animated: true) {
            player.play()
        }
    }
    
    
    
    
    
    
    
    
    
    
    func tempParser() {
        // 验证parser的使用
        // http://www.5tps.com/play/6931_52_1_1.html
        // 这个url为什么解析不了？？？
        //let baseUrlString = "http://www.5tps.com/play/6931_52_1_1.html"
        //let baidu = "http://news.cctv.com/2018/03/29/ARTIXM90XGYuzQ5CRvLBNmqT180329.shtml"
        //let xPath = "//*[@id=\"jp_audio_0\"]"
        
        //        let baseUrlString = "http://www.ysts8.com/play_6751_52_1_2.html"
        //        let xPath = "//*[@id=\"jp_audio_0\"]"
        //        let iframeXPath = "//*[@id=\"play\"]"
        //
        //        let jiDoc = Ji(htmlURL: URL(string: baseUrlString)!)
        //        let mp3Node = jiDoc?.xPath(xPath)
        //        let iframeNode = jiDoc?.xPath(iframeXPath)
        //        if let iframeNode = iframeNode?.first {
        //            let iframeUrlString = iframeNode["src"]
        //            print(iframeUrlString!)
        //
        //            let iframeDoc = Ji(htmlURL: URL.init(string: iframeUrlString!)!)
        //            let mp3Node = jiDoc?.xPath(xPath)
        //            print(mp3Node!)
        //        }
        
        let baseUrlString = "http://www.zgpingshu.com/down/3608/7.html"
        let xPath = "//*[@id=\"down\"]"
        let jiDoc = Ji(htmlURL: URL(string: baseUrlString)!)
        //let htmlNode = jiDoc?.rootNode
        let mp3Node = jiDoc?.xPath(xPath)
        let urlString = mp3Node?.first!["href"]
        
        
        print("\(String(describing: urlString))")
        
        let mp3UrlString = Helper.parseHTML(withUrl: URL.init(string: baseUrlString)!, xPath: xPath, attribute: "href")
        print(mp3UrlString!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
