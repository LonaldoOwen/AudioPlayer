//
//  ViewController.swift
//  AudioPlayer
//
//  Created by owen on 17/7/9.
//  Copyright © 2017年 owen. All rights reserved.
//
/// ViewController.swift
/// 功能：音频播放主页面
/// 
///



import UIKit
import AVFoundation
import MediaPlayer


class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet var audioTitle: UILabel!
    @IBOutlet var singer: UILabel!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet var volumeControl: UISlider!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var preBtn: UIButton!
    @IBOutlet var progress: UISlider!
    @IBOutlet var currentProgress: UILabel!
    @IBOutlet var leftProgress: UILabel!
    
    
    // MARK: - Properties
    
    var isPlaying: Bool = false
    var currentIndex: Int = 0
    var audioPlayer: AVAudioPlayer?
    var audioList: [AudioModel]!
    var musicDurationTimer: Timer!

    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("ViewController: viewDidLoad")
        
        // 获取数据(本地)
        audioList = Helper.readPropertyList()
        
        // UI setup
        setupUI()
        
        // audio player
//        let url = URL(fileURLWithPath: Bundle.main.path(forResource: audioList.first?.audioName, ofType: audioList.first?.audioType)!)
//        do {
//            try audioPlayer = AVAudioPlayer(contentsOf: url)
//            audioPlayer?.delegate = self
//            audioPlayer?.prepareToPlay()
//        } catch let error {
//            print("audioPlayer error: \(error.localizedDescription)")
//        }
        
        /**
         将实例化AVAudioPlayer抽象成方法
         */
        playAudio(forResource: (audioList.first?.audioName)!, ofType: (audioList.first?.audioType)!)
        
        // 注册后台播放，配置audio session
        registerBackgroundPlayback()
        
        // MPRemoteCommandCenter
        //lockScreenControlUsingMPRemoteCommandCenter()
        
        // 设置锁屏歌曲信息
        setLockScreenMusicInfo()
        
        // 注册通知
        registerForNotifications()
        
        // timer
        musicDurationTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(updateSliderValue), userInfo: nil, repeats: true)
        RunLoop.current.add(musicDurationTimer, forMode: RunLoopMode.commonModes)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ViewController: viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("ViewController: viewDidAppear")
        // 开始接收远程事件
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewController: viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("ViewController: viewDidDisappear")
        // 结束接收远程事件
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // 处理通知
    @objc
    func handelNotification(_ notification: NSNotification) {
        print("handelNotification")
        currentIndex = notification.userInfo?["index"] as! Int
        print(currentIndex)
        playerStop()
        audioTitle.text = audioList[currentIndex].audioName
//        audioPlayer = try? AVAudioPlayer(contentsOf: getUrl(audioList[currentIndex]))
        playAudio(forResource: audioList[currentIndex].audioName, ofType: audioList[currentIndex].audioType)
    }
    
    @objc
    func handelInterruption(_ notification: Notification) {
        // Handle interruption
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            // Interruption began, take appropriate actions (save state, update user interface)
            print("Interruption began")
            print("isPlaying: \(isPlaying)")    // true
            
        } else if type == .ended {
            guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
            }
            let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption Ended - playback should resume
                print("Interruption ended")
                print("isPlaying: \(isPlaying)")    // true
            }
        }
    }
    

    // MARK: actions
    
    // 调整进度
    @IBAction func ajustProgress(_ sender: UISlider) {
        print("ajustProgress")
        audioPlayer?.currentTime = Double(sender.value) * (audioPlayer?.duration)!
        updateProgressLabelValue()
    }
    
    // 音量
    @IBAction func ajustVolume(_ sender: Any) {
        if audioPlayer != nil {
            audioPlayer?.volume = volumeControl.value
        }
    }
    
    // 点击播放列表
    @IBAction func showPlayList(_ sender: UIButton) {
        print("showPlayList")
        let playListVC: PlayListViewController = PlayListViewController()
        playListVC.modalTransitionStyle = .crossDissolve
        playListVC.modalPresentationStyle = .overFullScreen // important
        self.present(playListVC, animated: true, completion: nil)
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
            currentIndex = audioList.count - 1
        }
        playerStop()
        audioTitle.text = audioList[currentIndex].audioName
        singer.text = audioList[currentIndex].musician
//        audioPlayer = try? AVAudioPlayer(contentsOf: getUrl(audioList[currentIndex]))
        playAudio(forResource: audioList[currentIndex].audioName, ofType: audioList[currentIndex].audioType)
        setLockScreenMusicInfo()
    }
    
    // 下一首
    @IBAction func playNext(_ sender: Any) {
        print("// 下一首")
        if currentIndex < audioList.count-1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        playerStop()
        audioTitle.text = audioList[currentIndex].audioName
        singer.text = audioList[currentIndex].musician
//        audioPlayer = try? AVAudioPlayer(contentsOf: getUrl(audioList[currentIndex]))
        playAudio(forResource: audioList[currentIndex].audioName, ofType: audioList[currentIndex].audioType)
        setLockScreenMusicInfo()
    }
    
    // 播放
    func playerPlay() {
        // change button image from play to pasue
        playBtn.setBackgroundImage(UIImage(named: "player_btn_pause_normal"), for: .normal)
        // play
        if let player = audioPlayer {
            player.play()
        }
    }
    // 暂停
    func playerPause() {
        // change button image from psuse to play
        playBtn.setBackgroundImage(UIImage(named: "player_btn_play_normal"), for: .normal)
        // pause
        if let player = audioPlayer {
            player.pause()
        }
    }
    // 停止
    func playerStop() {
        // change button image from pause to play
        playBtn.setBackgroundImage(UIImage(named: "player_btn_play_normal"), for: .normal)
        // stop
        if let player = audioPlayer {
            player.stop()
        }
    }
    
    // 更新slider
    @objc
    func updateSliderValue(_ timer: Any) {
        //print("updateSliderValue")
        guard let player = audioPlayer else {
            return
        }
        if player.isPlaying == true {
            let value = player.currentTime / player.duration
            progress.setValue(Float(value), animated: true)
            updateProgressLabelValue()
        }
    }
    
    // 更新progress label
    func updateProgressLabelValue() {
        if let player = audioPlayer {
            currentProgress.text = NSString.timeIntervalToMMSSFormat(timeInterval: player.currentTime) as String
            leftProgress.text = NSString.timeIntervalToMMSSFormat(timeInterval: (player.duration - player.currentTime)) as String
        }
    }
    
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //
        print("audioPlayerDidFinishPlaying")
        /**
         问题：播放第一首结束可以进入此方法中；第二首就不进了？？？
         原因：？？？
         解决：将实例化AVAudioPlayer抽象成方法后，可以（？？？）
        */
        if flag {
            playNext(nextBtn)
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        //
        print("audioPlayerDecodeErrorDidOccur")
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        //
        print("audioPlayerBeginInterruption")
    }
    
    
    // MARK: - Helper
    
    func setupUI() {
        self.title = "AudioPlayer"
        audioTitle.textColor = UIColor.white
        singer.textColor = UIColor.white
        //
        /**
         问题：1、tile使用的是url；2、中文未解析
         */
        audioTitle.text = audioList.first?.audioName
        singer.text = audioList.first?.musician
        self.cover.image = UIImage(named: "白鹿原封面.jpg")
        // buttons
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handelNotification),
                                               name: NSNotification.Name(rawValue: "PassIndex"),
                                               object: nil)
        // 注册通知（用于处理interruption）
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handelInterruption),
                                               name: .AVAudioSessionInterruption,
                                               object: AVAudioSession.sharedInstance())
    }
    
    // 生成mp3的URL(用于实例化AVAusioPlayer)
//    func getUrl(_ audio: AudioModel) -> URL {
//        let path = Bundle.main.path(forResource: audio.audioName, ofType: audio.audioType)
//        let url = URL(fileURLWithPath: path!)
//        return url
//    }
    
    // 播放audio实例
    func playAudio(forResource name: String, ofType ext: String) {
        let path = Bundle.main.path(forResource: name, ofType: ext)
        let url = URL(fileURLWithPath: path!)
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
        } catch let error {
            print("audioPlayer error: \(error.localizedDescription)")
        }
        if isPlaying {
            playerPlay()
            isPlaying = true
        }

    }
    
    // 设置锁屏显示歌曲信息（包括锁屏和控制中心）
    func setLockScreenMusicInfo() {
        
        let infoDic = [MPMediaItemPropertyTitle: audioList[currentIndex].audioName,
                       MPMediaItemPropertyArtist: audioList[currentIndex].musician,
                       MPMediaItemPropertyPlaybackDuration: self.audioPlayer!.duration] as [String : Any]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = infoDic
    }
    
    // MPRemoteCommandCenter 实现锁屏控制
    func lockScreenControlUsingMPRemoteCommandCenter() {
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
            self.playAudio(self.playBtn)    //
            return MPRemoteCommandHandlerStatus.success
        }
        // 暂停
        let pauseCommand = rcc.pauseCommand
        pauseCommand.addTarget { (command) -> MPRemoteCommandHandlerStatus in
            print("playCommand: \(command)")
            self.playAudio(self.playBtn)    //
            return MPRemoteCommandHandlerStatus.success

        }
        // 下一曲
        let nextCommand = rcc.nextTrackCommand
        nextCommand.isEnabled = true
        nextCommand.addTarget { (command) -> MPRemoteCommandHandlerStatus in
            print("nextCommand: \(command)")
            return MPRemoteCommandHandlerStatus.success
        }
    }
    
}

/// 处理远程事件
extension ViewController {
    
    override func remoteControlReceived(with event: UIEvent?) {
        
        if event?.type == UIEventType.remoteControl {
            switch event!.subtype {
            // remoteControlTogglePlayPause没有响应???
            case UIEventSubtype.remoteControlTogglePlayPause:
                print("//remoteControlTogglePlayPause")
                playAudio(playBtn)
            case UIEventSubtype.remoteControlPlay:
                print("//remoteControlPlay")
                //playerPlay()
                playAudio(playBtn)
            case UIEventSubtype.remoteControlPause:
                print("//remoteControlPause")
                //playerPause()
                playAudio(playBtn)
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



///
extension NSString {
    
    // 生成播放时长格式字符串
    class func timeIntervalToMMSSFormat(timeInterval ti: TimeInterval) -> NSString {
        let ti: Int = Int(ti)
        let seconds: Int = ti % 60
        let minutes: Int = (ti / 60) % 60
        return NSString.init(format: "%.2ld:%.2ld", minutes, seconds)
    }
    
}













