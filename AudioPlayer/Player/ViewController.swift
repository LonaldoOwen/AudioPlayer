//
//  ViewController.swift
//  AudioPlayer
//
//  Created by owen on 17/7/9.
//  Copyright © 2017年 owen. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet var audioTitle: UILabel!
    @IBOutlet var singer: UILabel!
    @IBOutlet var volumeControl: UISlider!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var preBtn: UIButton!
    @IBOutlet var progress: UISlider!
    @IBOutlet var currentProgress: UILabel!
    @IBOutlet var leftProgress: UILabel!
    
    var isPlaying: Bool = false
    var currentIndex: Int = 0
    var audioPlayer: AVAudioPlayer?
    var audioList: [AudioModel] = {
        var audioList: [AudioModel] = []
        // read property list
        let filePath = Bundle.main.path(forResource: "AudioList", ofType: "plist")
        let fileManager = FileManager.default
        let plistData = fileManager.contents(atPath: filePath!)
        let audioArray: [[String: String]] = try! PropertyListSerialization.propertyList(from: plistData!, options: [], format: nil) as! [[String : String]]
        for audioDict in audioArray {
            let audio: AudioModel = AudioModel(index: audioDict["index"]!, audioName: audioDict["audioName"]!, imageName: audioDict["imageName"]!, audioType: audioDict["audioType"]!)
            audioList.append(audio)
        }
        return audioList
    }()
    var musicDurationTimer: Timer!
    
    //
    var playButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        print("ViewController: viewDidLoad")
        // 
        self.title = "AudioPlayer"
        audioTitle.textColor = UIColor.white
        singer.textColor = UIColor.white
        
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
        //
        /**
         问题：1、tile使用的是url；2、中文未解析
         */
        audioTitle.text = audioList.first?.audioName
        
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
        
        // timer
        musicDurationTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(updateSliderValue), userInfo: nil, repeats: true)
        RunLoop.current.add(musicDurationTimer, forMode: RunLoopMode.commonModes)
        
        // 注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(handelNotification), name: NSNotification.Name(rawValue: "PassIndex"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ViewController: viewWillAppear")
    }
    override func viewDidAppear(_ animated: Bool) {
        print("ViewController: viewDidAppear")
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewController: viewWillDisappear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("ViewController: viewDidDisappear")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 处理通知
    @objc func handelNotification(_ notification: NSNotification) {
        print("handelNotification")
        currentIndex = notification.userInfo?["index"] as! Int
        print(currentIndex)
        playerStop()
        audioTitle.text = audioList[currentIndex].audioName
//        audioPlayer = try? AVAudioPlayer(contentsOf: getUrl(audioList[currentIndex]))
        playAudio(forResource: audioList[currentIndex].audioName, ofType: audioList[currentIndex].audioType)
    }
    

    /// MARK: actions
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
    
    // play button touchDown
    @IBAction func handlePlayTouchDown(_ sender: Any) {
        print("handlePlayTouchDown")
        if !isPlaying {
            //playing
            playBtn.setBackgroundImage(UIImage(named: "player_btn_play_highlight"), for: .highlighted)
        } else {
            // pause
            playBtn.setBackgroundImage(UIImage(named: "player_btn_pause_highlight"), for: .highlighted)
        }
    }
    // playback
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
//        audioPlayer = try? AVAudioPlayer(contentsOf: getUrl(audioList[currentIndex]))
        playAudio(forResource: audioList[currentIndex].audioName, ofType: audioList[currentIndex].audioType)
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
//        audioPlayer = try? AVAudioPlayer(contentsOf: getUrl(audioList[currentIndex]))
        playAudio(forResource: audioList[currentIndex].audioName, ofType: audioList[currentIndex].audioType)
    }
    
    // 播放
    func playerPlay() {
        // change button image from play to pasue
        playBtn.setBackgroundImage(UIImage(named: "player_btn_pause_normal"), for: .normal)
        // play
        if let player = audioPlayer {
            player.play()
            singer.text = "\(audioPlayer?.duration)"
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
    @objc func updateSliderValue(_ timer: Any) {
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
    
    
    /// MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //
        print("audioPlayerDidFinishPlaying")
        /**
         问题：播放第一首结束可以进入此方法中；第二首就不进了？？？
         解决：将实例化AVAudioPlayer抽象成方法后，可以？？？
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
    
    
    /// MARK: helper
    // 读取property list生成model数组
    func readPropertyList() -> [AudioModel] {
        var audioList: [AudioModel] = []
        // read property list
        let filePath = Bundle.main.path(forResource: "AudioList", ofType: "plist")
        let fileManager = FileManager.default
        let plistData = fileManager.contents(atPath: filePath!)
        let audioArray: [[String: String]] = try! PropertyListSerialization.propertyList(from: plistData!, options: [], format: nil) as! [[String : String]]
        for audioDict in audioArray {
            let audio: AudioModel = AudioModel(index: audioDict["index"]!, audioName: audioDict["audioName"]!, imageName: audioDict["imageName"]!, audioType: audioDict["audioType"]!)
            audioList.append(audio)
        }
        return audioList
    }
    // 生成mp3的URL
    func getUrl(_ audio: AudioModel) -> URL {
        let path = Bundle.main.path(forResource: audio.audioName, ofType: audio.audioType)
        let url = URL(fileURLWithPath: path!)
        return url
    }
    
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


