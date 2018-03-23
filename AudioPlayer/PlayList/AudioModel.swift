//
//  AudioModel.swift
//  AudioPlayer
//
//  Created by owen on 17/7/9.
//  Copyright © 2017年 owen. All rights reserved.
//
/// AudioModel
/// 功能：音频Data Model
///



import Foundation

struct AudioModel {
    
    // properties
    let index: String
    let audioName: String
    let imageName: String
    let audioType: String
    let musician: String
    
    // custom initializer
    init(index: String, audioName: String, imageName: String, audioType: String, musician: String) {
        self.index = index
        self.audioName = audioName
        self.imageName = imageName
        self.audioType = audioType
        self.musician = musician
    }
}
