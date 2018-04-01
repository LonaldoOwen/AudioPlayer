//
//  PlayerViewController.swift
//  AudioPlayer
//
//  Created by owen on 17/7/15.
//  Copyright © 2017年 owen. All rights reserved.
//
/**
 功能：
 1、使用Player来操作audio播放实例，查看和VC里创建AVAudioPlayer实例的区别
 2、
 */

import UIKit
import MediaPlayer

class PlayerViewController: UIViewController, PlayerDelegate {
    
    var isPlayingSb: Bool = false   // Storyboard 拉出来的button
    var player: Player?
    var audioList: [AudioModel]!
    var currentIndex: Int = 0
    var musicDurationTimer: Timer!

    ///
    @IBOutlet var preBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var audioName: UILabel!
    @IBOutlet var singer: UILabel!
    @IBOutlet var progress: UISlider!
    @IBOutlet var currentProgress: UILabel!
    @IBOutlet var leftProgress: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("PlayerViewController: viewDidLoad")
        
        // 使用自定义图片，关闭系统button默认高亮效果
        /**
         注意：当type = .custom时，此属性才生效，如果是.system不起作用；如果为true时，又设置了highlighted图像，那么会按highlighted图像效果
        */
        playBtn.adjustsImageWhenHighlighted = false
        
        //
        player = Player()
        audioList = Helper.readPropertyList()
        // 默认显示第一首歌曲
        player?.playAudio(audioList.first!)
        player?.delegate = self
        audioName.text = audioList.first?.audioName
        singer.text = audioList.first?.musician
        
        // 默认progress slider
        progress.minimumValue = 0
        progress.maximumValue = 1.0
        progress.value = 0.0
        
        // timer
        musicDurationTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(updateSliderValue), userInfo: nil, repeats: true)
        RunLoop.current.add(musicDurationTimer, forMode: RunLoopMode.commonModes)
        
        // MPRemoteCommandCenter 实现锁屏控制
        lockScreenControlUsingMPRemoteCommandCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("PlayerViewController: viewWillAppear")
    }
    override func viewDidAppear(_ animated: Bool) {
        print("PlayerViewController: viewDidAppear")
        // 1.2 接收远程事件
//        UIApplication.shared.beginReceivingRemoteControlEvents()
//        self.becomeFirstResponder()
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("PlayerViewController: viewWillDisappear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("PlayerViewController: viewDidDisappear")
        // 停止接收远程事件
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// actions
    
    // playback
    @IBAction func playback(_ sender: UIButton) {
        print("// playback")
        if !isPlayingSb {
            playBtn.setBackgroundImage(UIImage(named: "player_btn_pause_normal"), for: .normal)
            player?.audioPlayer?.play()
        } else {
            playBtn.setBackgroundImage(UIImage(named: "player_btn_play_normal"), for: .normal)
            player?.audioPlayer?.pause()
        }
        isPlayingSb = isPlayingSb ? false : true
    }
    //
    @IBAction func handlePlayTouchDown(_ sender: Any) {
        print("playBtn handleTouchDown")
        /// 这里可以根据sender类型，处理所有button的状态
        if !isPlayingSb {
            playBtn.setBackgroundImage(UIImage(named: "player_btn_play_highlight"), for: .highlighted)
        } else {
            playBtn.setBackgroundImage(UIImage(named: "player_btn_pause_highlight"), for: .highlighted)
        }
    }
    // 上一曲
    @IBAction func preBtnClick(_ sender: UIButton) {
        print("// 上一曲")
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            currentIndex = audioList.count - 1
        }
        audioName.text = audioList[currentIndex].audioName
        singer.text = audioList[currentIndex].musician
        player?.playAudio(audioList[currentIndex])
        if isPlayingSb {
            player?.play()
        }
    }
    // 下一曲
    @IBAction func nextBtnClick(_ sender: UIButton) {
        print("// 下一曲")
        if currentIndex < audioList.count-1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        //currentIndex = (currentIndex < audioList.count-1) ? (currentIndex + 1) : 0
        audioName.text = audioList[currentIndex].audioName
        singer.text = audioList[currentIndex].musician
        player?.playAudio(audioList[currentIndex])
        if isPlayingSb {
            player?.play()
        }
    }
    // 调整进度
    @IBAction func ajustProgress(_ sender: UISlider) {
        print("ajustProgress")
        if let player = player?.audioPlayer {
            player.currentTime = Double(sender.value) * (player.duration)
        }
        updateProgressLabelValue()
    }
    

    /// 
    
    // 更新slider
    @objc
    func updateSliderValue(_ timer: Any) {
        //print("updateSliderValue")
        guard let player = player?.audioPlayer else {
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
        if let player = player?.audioPlayer {
            currentProgress.text = NSString.timeIntervalToMMSSFormat(timeInterval: player.currentTime) as String
            leftProgress.text = NSString.timeIntervalToMMSSFormat(timeInterval: (player.duration - player.currentTime)) as String
        }
    }
    
    
    /// PlayerDelegate
    
    func playerDidFinishPlaying(_ player: Player, successfully flag: Bool) {
        print("//PlayerViewController: playerDidFinishPlaying")
        nextBtnClick(nextBtn)
    }
    
    /*
    /// 1.3 处理远程事件
    override func remoteControlReceived(with event: UIEvent?) {
        if event?.type == UIEventType.remoteControl {
            switch event!.subtype {
            // remoteControlTogglePlayPause没有响应???
            case UIEventSubtype.remoteControlTogglePlayPause:
                print("//remoteControlTogglePlayPause")
                playback(playBtn)
            case UIEventSubtype.remoteControlPlay:
                print("//remoteControlPlay")
                playback(playBtn)
            case UIEventSubtype.remoteControlPause:
                print("//remoteControlPause")
                //playerPause()
                playback(playBtn)
            case UIEventSubtype.remoteControlNextTrack:
                print("//remoteControlNextTrack")
                nextBtnClick(nextBtn)
            case UIEventSubtype.remoteControlPreviousTrack:
                print("//remoteControlPreviousTrack")
                preBtnClick(preBtn)
            default:
                break
            }
        }
    }
    */
    
    // 2.2 MPRemoteCommandCenter 实现锁屏控制
    func lockScreenControlUsingMPRemoteCommandCenter() {
        print("PlayerViewController: lockScreenControlUsingMPRemoteCommandCenter")
        
        let rcc = MPRemoteCommandCenter.shared()
        // 播放/暂停
        // togglePlayPauseCommand没有相应？？？
        let togglePlayPauseCommand = rcc.togglePlayPauseCommand
        togglePlayPauseCommand.isEnabled = true
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
            print("pauseCommand: \(command)")
            self.playback(self.playBtn)    //
            return MPRemoteCommandHandlerStatus.success
        }
        // 下一曲
        let nextCommand = rcc.nextTrackCommand
        nextCommand.isEnabled = true
        nextCommand.addTarget { (command) -> MPRemoteCommandHandlerStatus in
            print("nextCommand: \(command)")
            self.nextBtnClick(self.nextBtn)
            return MPRemoteCommandHandlerStatus.success
        }
        // 上一曲
        let preCommand = rcc.previousTrackCommand
        preCommand.isEnabled = true
        preCommand.addTarget { (command) -> MPRemoteCommandHandlerStatus in
            print("preCommand: \(command)")
            self.preBtnClick(self.preBtn)
            return MPRemoteCommandHandlerStatus.success
        }
        
    }
    
}








