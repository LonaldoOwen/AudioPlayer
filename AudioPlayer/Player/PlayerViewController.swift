//
//  PlayerViewController.swift
//  AudioPlayer
//
//  Created by owen on 03/04/2018.
//  Copyright © 2018 owen. All rights reserved.
//
/// PlayerViewController.swift
/// 功能：media的播放页面；原则：可以达到复用，尽量将处理过程房子player中进行，此处尽量少处理逻辑；
/// 1、目前使用AVPlayer实现播放音频功能；
/// 2、目前已实现：基本播放、界面更新、进度调整、显示加载过程、
/// 3、监听播放完毕
/// 4、播放进度调整
/// 5、应用Delegate调整UI及其他变化
///
/// 问题：
/// 1、float point 的NaN
///
///
///


import UIKit
import AVFoundation
import MediaPlayer


class PlayerViewController: UIViewController {
    
    static let reuseIdentifier = "AVPlayerVC"
    
    
    @IBOutlet var audioTitle: UILabel!
    @IBOutlet var singer: UILabel!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet var volumeControl: UISlider!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var preBtn: UIButton!
    @IBOutlet weak var backProgress: UIProgressView!
    @IBOutlet var progress: UISlider!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    
    
    // MARK: - Properties
    
    var book: Book!
    var chapter: Chapter!
    var chapters: [Chapter]!
    var isPlaying: Bool = false
    var currentIndex: Int = 0
    var moplayer: MOAVPlayer!
    var avplayer: AVPlayer! {
        return moplayer.player
    }
    var currentAVPlayerItem: AVPlayerItem! {
        return avplayer.currentItem
    }
    var timeObserverToken: Any?
    let avPlayerQueue = DispatchQueue(label: "com.owen.queeu")
    
    
    
    // MARK: - Actions
    
    // 调整进度
    @IBAction func ajustProgress(_ sender: UISlider) {
        print("#PlayerViewController: ajustProgress")
        
        let total = CMTimeGetSeconds(self.currentAVPlayerItem.duration)
        let seekTime = CMTime(seconds: Double(sender.value) * total, preferredTimescale: 1)
        let current = CMTimeGetSeconds(seekTime)
        /**
         调整播放进度的主要方法
         */
        avplayer.seek(to: seekTime) { (finished) in
            if finished {
                print("Seeking time finished!")
                // update progress labels
                print("current: \(current), total: \(total)")
                self.updateProgressLabelValue(current: current, total: total)
            }
        }

    }
    
    // 音量
    @IBAction func ajustVolume(_ sender: Any) {
        print("PlayerViewController: ajustVolume")
        
        //
    }
    
    // 播放列表
    @IBAction func showPlayList(_ sender: UIButton) {
        print("PlayerViewController: showPlayList")
        
        //
    }
    
    // play button touchDown(切换图标)
    @IBAction func handlePlayTouchDown(_ sender: Any) {
        print("#PlayerViewController: handlePlayTouchDown")
        
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
    @IBAction func playback(_ sender: Any) {
        print("#PlayerViewController: playback")
        
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
    
    // handle double tap gesture
    @objc func handleDoubleTapGesture(_ recognizer: UIGestureRecognizer) {
        // close current VC
        print("#close current VC!")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("#AVPlayerViewController: viewDidLoad")
        
        
        // UI setup
        setupUI()
        
        /// 问题：未使用单例时，返回列表播放新的audio，会同时播放两个audio
        /// 原因：???
        /// 解决：使用singleton
        //moplayer = MOAVPlayer()
        //moplayer = MOAVPlayer.sharedMOAVPlayer
        //moplayer.player(withChapter: chapters[currentIndex])
        // 异步处理
//        avPlayerQueue.async {
//            self.moplayer.player(withChapter: self.chapters[self.currentIndex])
//        }
        //        avplayer = moplayer.player
        //        currentAVPlayerItem = avplayer.currentItem
        
        // 监听（播放进度）
        //addPeriodicTimeObserver()
        
        // 更新player UI
        // 问题：此时还获取不到player item的duration信息？？？
        //updatePlayerUI()
        
        // 注册后台播放，配置audio session
        //registerBackgroundPlayback()
        
        // 设置锁屏歌曲信息
        //setLockScreenMusicInfo()
        
        // 锁屏控制：1.MPRemoteCommandCenter
        //lockScreenControlUsingMPRemoteCommandCenter()
        
        // 注册通知
        registerForNotifications()
        
        // add double tap gestrue recognizer
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("#PlayerViewController: viewDidAppear")
        //
        moplayer = MOAVPlayer.sharedMOAVPlayer
        moplayer.delegate = self
        moplayer.player(withChapter: chapters[currentIndex])
        updatePlayerUI()
        // 设置锁屏歌曲信息
        //setLockScreenMusicInfo()
        // 锁屏控制：1.MPRemoteCommandCenter
        //lockScreenControlUsingMPRemoteCommandCenter()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Register notifications
    
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
    
    
    
    // MARK: - Helper
    
    // setup UI
    func setupUI() {
        self.title = "AVPlayer"
        
        audioTitle.textColor = UIColor.white
        singer.textColor = UIColor.white
        self.playBtn.adjustsImageWhenHighlighted = false
        
        // 自定义progress UI
        
        progress.setMinimumTrackImage(UIImage(named: "player_slider_playback_left"), for: .normal)
        //progress.setMaximumTrackImage(UIImage(named: "player_slider_playback_right"), for: .normal)
        progress.setThumbImage(UIImage(named: "player_slider_playback_thumb"), for: .normal)
        
        // progress slider
        progress.minimumValue = 0
        progress.maximumValue = 1.0
        progress.value = 0.0
        backProgress.progress = progress.value
    }
    
    // 更新player的UI（title、singer等）
    func updatePlayerUI() {
        let chapter = chapters[currentIndex]
        audioTitle.text = chapter.title
        singer.text = chapter.reader
        self.cover.image = UIImage(named: "image_mcnxs.jpg")
        
        // 此时还获取不到player item的信息，因为asset的status还没变为loaded；
        //self.totalTimeLabel.text = NSString.timeIntervalToMMSSFormat(timeInterval: CMTimeGetSeconds(currentAVPlayerItem.duration)) as String
    }
    
    // 更新progress label
    func updateProgressLabelValue(current: TimeInterval, total: TimeInterval) {
        currentTimeLabel.text = NSString.timeIntervalToMMSSFormat(timeInterval: current) as String
        totalTimeLabel.text = NSString.timeIntervalToMMSSFormat(timeInterval: total - current) as String
    }
    
    // 播放
    func playerPlay() {
        print("#PlayerViewController: playerPlay")
        
        // change button image from play to pasue
        playBtn.setBackgroundImage(UIImage(named: "player_btn_pause_normal"), for: .normal)
        // play
        guard let moplayer = moplayer else {
            //
            return
        }
        moplayer.play()
        // 监听(播放完成)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerFinished),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: moplayer.player.currentItem)
        
    }
    @objc func playerFinished() {
        print("#播放完成！")
        // 播放下一首
        currentIndex = currentIndex + 1
        playerPlayNext()
    }
    
    // 播放下一首
    func playerPlayNext() {
        print("#PlayerViewController: playerPlayNext")
        
        // 移除监听(播放完成)
        NotificationCenter.default.removeObserver(self)
        
        if let moplayer = moplayer {
            updatePlayerUI()
            moplayer.player(withChapter: chapters[currentIndex])
            //addPeriodicTimeObserver()
            if isPlaying {
                playerPlay()
                isPlaying = true
            }
            
        }
    }
    
    // 暂停
    func playerPause() {
        print("#PlayerViewController: playerPause")
        // change button image from psuse to play
        playBtn.setBackgroundImage(UIImage(named: "player_btn_play_normal"), for: .normal)
        
        // pause
        if let moplayer = moplayer {
            moplayer.pause()
        }
    }
    
    
    
    // MARK: - Lock screen play
    
    // 设置锁屏显示歌曲信息（包括锁屏和控制中心）
    func setLockScreenMusicInfo() {
        
        let infoDic = [MPMediaItemPropertyTitle: chapters[currentIndex].title,
                       MPMediaItemPropertyArtist: chapters[currentIndex].reader,
                       MPMediaItemPropertyPlaybackDuration: currentAVPlayerItem.duration] as [String : Any]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = infoDic
    }
    
    // 2.0 MPRemoteCommandCenter 实现锁屏控制
    func lockScreenControlUsingMPRemoteCommandCenter() {
        print("# lockScreenControlUsingMPRemoteCommandCenter")
        
        let rcc = MPRemoteCommandCenter.shared()
        // 播放/暂停
        // togglePlayPauseCommand没有相应？？？
        let togglePlayPauseCommand = rcc.togglePlayPauseCommand
        togglePlayPauseCommand.isEnabled = true
        //togglePlayPauseCommand.addTarget(self, action: #selector(handleRC))
        togglePlayPauseCommand.addTarget { (command) -> MPRemoteCommandHandlerStatus in
            print("togglePlayPauseCommand: \(command)")
            return MPRemoteCommandHandlerStatus.success
        }
        // 播放
        let playCommand = rcc.playCommand
        playCommand.isEnabled = true
        playCommand.addTarget { (command) -> MPRemoteCommandHandlerStatus in
            print("playCommand: \(command)")
            self.playback(self.playBtn)    //
            return MPRemoteCommandHandlerStatus.success
        }
        // 暂停
        let pauseCommand = rcc.pauseCommand
        pauseCommand.addTarget { (command) -> MPRemoteCommandHandlerStatus in
            print("playCommand: \(command)")
            self.playback(self.playBtn)    //
            return MPRemoteCommandHandlerStatus.success
            
        }
        // 下一曲
        let nextCommand = rcc.nextTrackCommand
        nextCommand.isEnabled = true
        nextCommand.addTarget { (command) -> MPRemoteCommandHandlerStatus in
            print("nextCommand: \(command)")
            self.playNext(self.nextBtn)
            return MPRemoteCommandHandlerStatus.success
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



// MARK: - 实现MOAVPlayerDelegate
extension PlayerViewController: MOAVPlayerDelegate {
    
    // 解析HTML
    func moavplayer(_ moavplayer: MOAVPlayer, parseHTMLResult result: Bool, urlString: String) {
        print("#PlayerViewController: 解析HTML")
        if result {
            print("#PlayerViewController: Get parseHTMLResult: \(urlString) ")
            // HTML解析成功，结束菊花
            // 解析成功再创建播放实例
        } else {
            print("#PlayerViewController: Get parseHTMLResult: nil")
        }
    }
    
    // asset 加载状态
    func moavplayer(_ moavplayer: MOAVPlayer, assetDidLoaded status: AVKeyValueStatus) {
        print("#PlayerViewController: asset 加载状态")
        if status == .loaded {
            let totalTime = CMTimeGetSeconds(moavplayer.playItem.duration)
            guard !totalTime.isNaN else { return }
            self.updateProgressLabelValue(current: 0.0, total: totalTime)
            // 设置锁屏歌曲信息
            setLockScreenMusicInfo()
            // 锁屏控制：1.MPRemoteCommandCenter
            lockScreenControlUsingMPRemoteCommandCenter()
        }
    }
    
    // 播放状态
    func moavplayer(_ moavplayer: MOAVPlayer, playerItemDidReadyToPlay status: AVPlayerItemStatus) {
        print("#PlayerViewController: 播放状态")
        
        if status == .readyToPlay {
            print("#PlayerViewController: readyToPlay")
            if isPlaying {
                playerPlay()
            }
        }
    }
    
    // 加载进度
    func moavplayer(_ moavplayer: MOAVPlayer, playerItemLoadedTime time: TimeInterval) {
        print("#PlayerViewController: 加载进度")
        
        let total = CMTimeGetSeconds(moavplayer.playItem.duration)
        self.backProgress.progress = Float(time / total)
        //print("#backprogress.progress: \(self.backProgress.progress)")
    }
    
    // 播放进度监听
    func moavplayer(_ moavplayer: MOAVPlayer, periodicTimeDidChange time: CMTime) {
        print("#PlayerViewController: 播放进度监听")
        
        // update player transport UI
        //print("#Get time: \(time)")
        guard let playerItem = moplayer.playItem else {
            print("##PlayerViewController: current playerItem is nil!")
            return
        }
        let currentTime = CMTimeGetSeconds(time)
        let totalTime = CMTimeGetSeconds(playerItem.duration)
//        print("currentTime: \(currentTime)")
//        print("totalTime: \(totalTime)")

        guard !currentTime.isNaN, !totalTime.isNaN else { return }
        self.progress.value = Float(currentTime / totalTime)
        // update progress labels
        self.updateProgressLabelValue(current: currentTime, total: totalTime)
    }
}


/// 1.3 处理远程事件
extension PlayerViewController {
    
    override func remoteControlReceived(with event: UIEvent?) {
        
        if event?.type == UIEventType.remoteControl {
            switch event!.subtype {
            // remoteControlTogglePlayPause没有响应???
            case UIEventSubtype.remoteControlTogglePlayPause:
                print("//remoteControlTogglePlayPause")
                playback(playBtn)
            case UIEventSubtype.remoteControlPlay:
                print("//remoteControlPlay")
                //playerPlay()
                playback(playBtn)
            case UIEventSubtype.remoteControlPause:
                print("//remoteControlPause")
                //playerPause()
                playback(playBtn)
            case UIEventSubtype.remoteControlNextTrack:
                print("//remoteControlNextTrack")
                playNext(nextBtn)
            case UIEventSubtype.remoteControlPreviousTrack:
                print("//remoteControlPreviousTrack")
                playPre(preBtn)
            default:
                break
            }
        }
    }
    
}




