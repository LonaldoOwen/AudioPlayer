//
//  Helper.swift
//  AudioPlayer
//
//  Created by owen on 17/8/12.
//  Copyright © 2017年 owen. All rights reserved.
//

import Foundation

class Helper {
    
    /// 读取property list生成model数组
    static func readPropertyList() -> [AudioModel] {
        var audioList: [AudioModel] = []
        // read property list
        let filePath = Bundle.main.path(forResource: "AudioList", ofType: "plist")
        let fileManager = FileManager.default
        let plistData = fileManager.contents(atPath: filePath!)
        let audioArray: [[String: String]] = try! PropertyListSerialization.propertyList(from: plistData!, options: [], format: nil) as! [[String : String]]
        for audioDict in audioArray {
            let audio: AudioModel = AudioModel(index: audioDict["index"]!,
                                               audioName: audioDict["audioName"]!,
                                               imageName: audioDict["imageName"]!,
                                               audioType: audioDict["audioType"]!,
                                               musician: audioDict["musician"]!)
            audioList.append(audio)
        }
        return audioList
    }
    
}

