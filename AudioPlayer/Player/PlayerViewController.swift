//
//  PlayerViewController.swift
//  AudioPlayer
//
//  Created by owen on 03/04/2018.
//  Copyright © 2018 owen. All rights reserved.
//

import UIKit
import AVFoundation





class PlayerViewController: UIViewController {
    
    static let reuseIdentifier = "AVPlayerVC"
    
    
    @IBOutlet var audioTitle: UILabel!
    @IBOutlet var singer: UILabel!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet var volumeControl: UISlider!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var preBtn: UIButton!
    @IBOutlet var progress: UISlider!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    
    
    // MARK: - Properties
    
    var isPlaying: Bool = false
    var currentIndex: Int = 0
    var book: Book!
    var chapter: Chapter!
    var chapters: [Chapter]!
    var moplayer: MOAVPlayer!
    var avplayer: AVPlayer!
    var currentAVPlayerItem: AVPlayerItem!
    var timeObserverToken: Any?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("AVPlayerViewController: viewDidLoad")
        
        
        // UI setup
        setupUI()
        updatePlayerUI()
        
        /// 问题：未使用单例时，返回列表播放新的audio，会同时播放两个audio
        /// 原因：???
        /// 解决：使用singleton
        //moplayer = MOAVPlayer()
        moplayer = MOAVPlayer.sharedMOAVPlayer
        moplayer.player(withChapter: chapters[currentIndex])
//        avplayer = moplayer.player
//        currentAVPlayerItem = avplayer.currentItem
        // 监听（播放进度）
        addPeriodicTimeObserver()
        
        // 注册后台播放，配置audio session
        //registerBackgroundPlayback()
        
        // MPRemoteCommandCenter
        //lockScreenControlUsingMPRemoteCommandCenter()
        
        // 设置锁屏歌曲信息
        //setLockScreenMusicInfo()
        
        // 注册通知
        registerForNotifications()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    
    // 调整进度
    @IBAction func ajustProgress(_ sender: UISlider) {
        print("ajustProgress")

    }
    
    // 音量
    @IBAction func ajustVolume(_ sender: Any) {
        print("ajustVolume")
    }
    
    // 点击播放列表
    @IBAction func showPlayList(_ sender: UIButton) {
        print("showPlayList")

    }
    
    // play button touchDown(切换图标)
    @IBAction func handlePlayTouchDown(_ sender: Any) {
        print("handlePlayTouchDown")
        
        /// 这里可以根据sender类型，处理所有button的状态
        if !isPlaying {
            //playing
            playBtn.setBackgroundImage(UIImage(named: "player_btn_play_highlight"), for: .highlighted)
        } else {
            // pause
            playBtn.setBackgroundImage(UIImage(named: "player_btn_pause_highlight"), for: .highlighted)
        }
    }
    
    // playback(toggle play and pause)
    @IBAction func playAudio(_ sender: Any) {
        print("playAudio")
        
        if !isPlaying {
            // playing
            playerPlay()
        } else {
            // pause
            playerPause()
        }
        isPlaying = isPlaying ? false : true
    }
    
    // 上一首
    @IBAction func playPre(_ sender: Any) {
        print("// 上一首")
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            currentIndex = chapters.count - 1
        }
        
        updatePlayerUI()
        moplayer.player(withChapter: chapters[currentIndex])
        if isPlaying {
            playerPlay()
            isPlaying = true
        }
        
        //setLockScreenMusicInfo()
    }
    
    // 下一首
    @IBAction func playNext(_ sender: Any) {
        print("// 下一首")
        if currentIndex < chapters.count-1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        
        // 播放下一首
        playerPlayNext()
//        setLockScreenMusicInfo()
    }
    
    
    
    // MARK: - Helper
    
    // setup UI
    func setupUI() {
        self.title = "AVPlayer"
        
        audioTitle.textColor = UIColor.white
        singer.textColor = UIColor.white
        self.playBtn.adjustsImageWhenHighlighted = false
        
        // progress
        progress.setMinimumTrackImage(UIImage(named: "player_slider_playback_left"), for: .normal)
        progress.setMaximumTrackImage(UIImage(named: "player_slider_playback_right"), for: .normal)
        progress.setThumbImage(UIImage(named: "player_slider_playback_thumb"), for: .normal)
        
        // progress slider
        progress.minimumValue = 0
        progress.maximumValue = 1.0
        progress.value = 0.0
    }
    
    // 更新player的UI（title、singer等）
    func updatePlayerUI() {
        let chapter = chapters[currentIndex]
        audioTitle.text = chapter.title
        singer.text = chapter.reader
        self.cover.image = UIImage(named: "image_mcnxs.jpg")
    }
    
    // 注册后台播放，配置audio session
    func registerBackgroundPlayback() {
        let session = AVAudioSession.sharedInstance()
        do {
            // Configure the audio session for music playback
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        } catch let error as NSError {
            print("Failed to set the audio session category and mode: \(error.localizedDescription)")
        }
    }
    
    // 注册通知
    func registerForNotifications() {
        // 注册通知（用于列表传值）
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handelPassIndexNotification),
//                                               name: NSNotification.Name(rawValue: "PassIndex"),
//                                               object: nil)
        // 注册通知（用于处理interruption）
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handelInterruption),
//                                               name: .AVAudioSessionInterruption,
//                                               object: AVAudioSession.sharedInstance())
        
        //
        
    }

    
    
    
    // 播放
    func playerPlay() {
        // change button image from play to pasue
        playBtn.setBackgroundImage(UIImage(named: "player_btn_pause_normal"), for: .normal)
        // play
        if let moplayer = moplayer {
            moplayer.play()
            // 监听(播放完成)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerFinished),
                                                   name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: moplayer.player.currentItem)
        }
    }
    @objc func playerFinished() {
        // 播放下一首
        playerPlayNext()
    }
    
    // 播放下一首
    func playerPlayNext() {
        // 移除监听(播放完成)
        NotificationCenter.default.removeObserver(self)
        // 移除（PeriodicTimeObserver）
        removePeriodicTimeObserver()
        
        if let moplayer = moplayer {
            currentIndex = currentIndex + 1
            updatePlayerUI()
            moplayer.player(withChapter: chapters[currentIndex])
            addPeriodicTimeObserver()
            if isPlaying {
                playerPlay()
                isPlaying = true
            }
            
        }
    }
    
    // 暂停
    func playerPause() {
        // change button image from psuse to play
        playBtn.setBackgroundImage(UIImage(named: "player_btn_play_normal"), for: .normal)
        
        // pause
        if let moplayer = moplayer {
            moplayer.pause()
        }
    }
    
    // add PeriodicTimeObserver
    func addPeriodicTimeObserver() {
        print("#addPeriodicTimeObserver:")
        avplayer = moplayer.player
        currentAVPlayerItem = avplayer.currentItem
        
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = avplayer.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            // update player transport UI
            let currentTime = CMTimeGetSeconds(time)
            let totalTime = CMTimeGetSeconds((self?.currentAVPlayerItem.duration)!)
            print("currentTime: \(currentTime)")
            print("totalTime: \(totalTime)")
            self?.progress.value = Float(currentTime / totalTime)
            self?.currentTimeLabel.text = NSString.timeIntervalToMMSSFormat(timeInterval: currentTime) as String
            self?.totalTimeLabel.text = NSString.timeIntervalToMMSSFormat(timeInterval: totalTime - currentTime) as String
            
        }
        
    }
    
    // remove PeriodicTimeObserver
    func removePeriodicTimeObserver() {
        print("#removePeriodicTimeObserver:")
        if let timeObserverToken = timeObserverToken {
            avplayer.removeTimeObserver(timeObserverToken)
        }
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
