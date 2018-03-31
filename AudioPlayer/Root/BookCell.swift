//
//  BookCell.swift
//  AudioPlayer
//
//  Created by libowen on 2018/3/30.
//  Copyright © 2018年 owen. All rights reserved.
//
/// BookCell.swift
/// 功能：书籍列表中书籍cell(自定义)
/// 1、复写subtle样式，增加titleLabel可以多行展示，其他不变
///


import UIKit

class BookCell: UITableViewCell {
    
    // properties
    var model: Book? {
        didSet {
            imageView?.image = UIImage.init(named: (model?.imageString)!)
            textLabel?.text = model?.name
            detailTextLabel?.text = "作者:" + (model?.author)! + " 播讲：" + (model?.reader)!
        }
    }
    
    // init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
