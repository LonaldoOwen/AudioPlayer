//
//  Helper.swift
//  AudioPlayer
//
//  Created by owen on 17/8/12.
//  Copyright © 2017年 owen. All rights reserved.
//
/// Helper
/// 功能：常用功能帮助文件
///
///

import Foundation
import Ji

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


extension Helper {
    
    // 请求数据NSURLSession
    static func requestData(withString urlString: String) -> Data? {
        
        
        let session = URLSession.shared
//        var request = URLRequest(url: URL(string: urlString)!)
//        request.httpMethod = "GET"
        var returnData: Data?
        let task = session.dataTask(with: URL(string: urlString)!, completionHandler: { data, response, error in
            returnData = data
            
            //let jiDoc = Ji.init(htmlData: data!)
            //let jiDoc = Ji.init(xmlURL: URL.init(string: "http://www.5tps.com/play/6931_52_1_1.html")!)
            //let jiDoc = Ji.init(htmlString: "http://www.5tps.com/play/6931_52_1_1.html")
//            let jiDoc = Ji.init(htmlURL: URL.init(string: baseUrlString2)!)
//            let htmlNode = jiDoc?.rootNode
//            print("\(String(describing: htmlNode))")
        })
        task.resume()
        
        return returnData
    }
}



extension Helper {
    static func parseHTML(withUrl url: URL, xPath: String, attribute: String) -> String? {
        
        let jiDoc = Ji.init(htmlURL: url)
        let mp3Node = jiDoc?.xPath(xPath)
        let mp3UrlString = mp3Node?.first![attribute]
        print("mp3UrlString: \(String(describing: mp3UrlString))")
        return mp3UrlString
    }
}










