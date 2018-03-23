//
//  PlayListTableViewCell.swift
//  AudioPlayer
//
//  Created by owen on 17/7/18.
//  Copyright © 2017年 owen. All rights reserved.
//
/// PlayListTableViewCell
/// 功能：音频列表的自定义cell
/// 
///
///
///


import UIKit

class PlayListTableViewCell: UITableViewCell {
    
    /// 自定义控件
    let title: UILabel = {
        let label = UILabel()
        //label.backgroundColor = UIColor.lightGray
        label.numberOfLines = 2
        return label
    }()
    let index: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    /// 初始化设置
    func setUp() {
        self.contentView.addSubview(index)
        self.contentView.addSubview(title)
        
        index.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        
        index.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        index.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        index.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        title.leadingAnchor.constraint(equalTo: index.trailingAnchor, constant: 10).isActive = true
        title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
    }
    
    /// 覆写初始化方法
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// model属性
    var audioModel: AudioModel? {
        didSet {
            self.title.text = audioModel?.audioName
            self.index.text = audioModel?.index
            //
        }
    }
    
    /// click closure
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
