//
//  ParseViewController.swift
//  AudioPlayer
//
//  Created by owen on 29/03/2018.
//  Copyright © 2018 owen. All rights reserved.
//

import UIKit
import Ji

class ParseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 验证parser的使用
        // http://www.5tps.com/play/6931_52_1_1.html
        // 这个url为什么解析不了？？？
        let baseUrlString = "http://www.5tps.com"
        let baidu = "http://news.cctv.com/2018/03/29/ARTIXM90XGYuzQ5CRvLBNmqT180329.shtml"
        let xPath = "//*[@id=\"jp_audio_0\"]"
        
        let jiDoc = Ji(htmlURL: URL(string: baseUrlString)!)
        let mp3Node = jiDoc?.xPath(xPath)
        print("\(String(describing: mp3Node))")
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
