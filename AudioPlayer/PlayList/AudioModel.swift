//
//  AudioModel.swift
//  AudioPlayer
//
//  Created by owen on 17/7/9.
//  Copyright © 2017年 owen. All rights reserved.
//

import Foundation

struct AudioModel {
    
    let index: String
    let audioName: String
    let imageName: String
    let audioType: String
    let musician: String
    
    init(index: String, audioName: String, imageName: String, audioType: String, musician: String) {
        self.index = index
        self.audioName = audioName
        self.imageName = imageName
        self.audioType = audioType
        self.musician = musician
    }
}
