//
//  ChapterListCell.swift
//  AudioPlayer
//
//  Created by libowen on 2018/3/30.
//  Copyright © 2018年 owen. All rights reserved.
//

import UIKit

class ChapterListCell: UITableViewCell {
    
    static let reuseIdentifier = "ChapterCell"
    
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    
    var model: Chapter? {
        didSet {
            indexLabel.text = model?.index
            titleLabel.text = model?.title
            downloadLabel.text = "未下载"
            durationLabel.text = "03:56"
            moreButton.setTitle("more", for: .normal)
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
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
