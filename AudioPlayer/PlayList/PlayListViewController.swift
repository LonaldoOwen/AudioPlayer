//
//  PlayListViewController.swift
//  AudioPlayer
//
//  Created by owen on 17/7/17.
//  Copyright © 2017年 owen. All rights reserved.
//

import UIKit

class PlayListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    ///
    let backgroundView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200)
        //view.backgroundColor = UIColor.orange
        return view
    }()
    var tableView: UITableView!
    let closeView: UIView = {
        let closeView = UIView()
        closeView.backgroundColor = UIColor.white
        let label = UILabel()
        label.text = "关闭"
        label.textColor = UIColor.black
        closeView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: closeView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: closeView.centerYAnchor).isActive = true
        return closeView
    }()
    let topView: UIView = {
        let topView = UIView()
        topView.backgroundColor = UIColor.white
        return topView
    }()
    let onePixlBottom: UIView = {
        let one = UIView()
        one.backgroundColor = UIColor.black
        return one
    }()
    let onePixlTop: UIView = {
        let one = UIView()
        one.backgroundColor = UIColor.black
        return one
    }()
    
    var audioList: [AudioModel]?
    var indexToPlay: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //
        view.backgroundColor = UIColor(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 0.3)
        view.addSubview(backgroundView)
        
        backgroundView.addSubview(topView)
        topView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(onePixlBottom)
        onePixlBottom.translatesAutoresizingMaskIntoConstraints = false
        
        tableView = UITableView()
        backgroundView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 88
        
        backgroundView.addSubview(onePixlTop)
        onePixlTop.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(closeView)
        closeView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        closeView.addGestureRecognizer(tapGesture)
        setUpConstraints()
        
        //
        audioList = readPropertyList()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("PlayListViewController: viewWillAppear")
        //
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.frame = CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200)
        }, completion: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        print("PlayListViewController: viewDidAppear")
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("PlayListViewController: viewWillDisappear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("PlayListViewController: viewDidDisappear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// MARK: data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (audioList?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ListCell"
        var cell: PlayListTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as! PlayListTableViewCell?
        if cell == nil {
            cell = PlayListTableViewCell(style: .default, reuseIdentifier: identifier)
        }
        cell?.audioModel = audioList?[indexPath.row]
        return cell!
    }
    
    
    /// MARK: delegate
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        indexToPlay = indexPath.row
        // 发送通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PassIndex"), object: nil, userInfo: ["index": indexToPlay])
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: false)
        dismissWithAnimation()
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("didDeselectRowAt: \(indexPath.row)")
    }
    
    
    // 设置控件约束
    func setUpConstraints() {
        let views: [String: Any] = ["table": tableView, "close": closeView, "top": topView, "oneBottom": onePixlBottom, "oneTop": onePixlTop]
        let table_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[table]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let table_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[top(54)]-0-[oneBottom(0.5)]-0-[table]-0-[oneTop(0.5)]-0-[close(54)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let topView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[top]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views)
        let oneBottom_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[top]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views)
        let oneTop_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[top]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views)
        let closeView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[close]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views)
        backgroundView.addConstraints(table_H)
        backgroundView.addConstraints(table_V)
        backgroundView.addConstraints(topView_H)
        backgroundView.addConstraints(oneBottom_H)
        backgroundView.addConstraints(oneTop_H)
        backgroundView.addConstraints(closeView_H)
    }
    
    // 点击关闭button
    @objc func handleTap() {
        dismissWithAnimation()
    }
    
    
    /// MARK: helper
    // 读取property lsit
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
    
    //
    func dismissWithAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200)
        }, completion: nil)
        
        self.dismiss(animated: true, completion: nil)
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
