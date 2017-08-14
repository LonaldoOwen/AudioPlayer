//
//  TempViewController.swift
//  AudioPlayer
//
//  Created by owen on 17/8/13.
//  Copyright © 2017年 owen. All rights reserved.
//

import UIKit

class TempViewController: UIViewController {
    
    /// properties
    let tempBtn: UIButton = {
        /**
         type = .system,是系统button，样式和操作都设置好了，默认adjustsImageWhenHighlighted ＝ true，按住button时会调整highlighted图像，使图片变暗（这个效果是系统设置好的）；如果想自己设置highlighted图片，可以设置type ＝ .custom
         */
        let tempBtn = UIButton(type: .custom)
        return tempBtn
    }()
    var isPlaying: Bool = false     // 代码创建的button，使用
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //
        
         view.addSubview(tempBtn)
         tempBtn.translatesAutoresizingMaskIntoConstraints = false
         tempBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
         tempBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
         tempBtn.setBackgroundImage(UIImage(named: "player_btn_play_normal"), for: .normal)//player_btn_play_normal@2x.png
         tempBtn.addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
         tempBtn.addTarget(self, action: #selector(handleClick), for: .touchUpInside)
         //tempBtn.adjustsImageWhenHighlighted = false
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///
    
    // touchDown
    @objc
    func handleTouchDown(_ sender: UIButton!) {
        print("tempBtn handleTouchDown")
        if !isPlaying {
            tempBtn.setBackgroundImage(UIImage(named: "player_btn_play_highlight"), for: .highlighted)
        } else {
            tempBtn.setBackgroundImage(UIImage(named: "player_btn_pause_highlight"), for: .highlighted)
        }
    }
    // touchUpInset
    @objc
    func handleClick(_ sender: Any) {
        print("tempBtn clicked!")
        if !isPlaying {
            // playing
            tempBtn.setBackgroundImage(UIImage(named: "player_btn_pause_normal"), for: .normal)
        } else {
            // pause
            tempBtn.setBackgroundImage(UIImage(named: "player_btn_play_normal"), for: .normal)
        }
        isPlaying = isPlaying ? false : true
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
