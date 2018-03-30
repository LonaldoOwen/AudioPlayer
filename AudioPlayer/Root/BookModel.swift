//
//  BookModel.swift
//  AudioPlayer
//
//  Created by libowen on 2018/3/30.
//  Copyright © 2018年 owen. All rights reserved.
//

import Foundation



struct Book {
    
    // properties
    let name: String
    let author: String
    let reader: String
    let imageString: String
    let count: Int
    let baseUrlString: String
    
    init(name: String, author: String, reader: String, imageString: String, count: Int, baseUrlString: String) {
        self.name = name
        self.author = author
        self.reader = reader
        self.imageString = imageString
        self.count = count
        self.baseUrlString = baseUrlString
    }
}


struct Chapter {
    
    // properties
    let index: String
    let title: String
    let reader: String
    let duration: String
    let urlString: String
    
    init(index: String, title: String, reader: String, duration: String, urlString: String) {
        self.index = index
        self.title = title
        self.reader = reader
        self.duration = duration
        self.urlString = urlString
    }
}















