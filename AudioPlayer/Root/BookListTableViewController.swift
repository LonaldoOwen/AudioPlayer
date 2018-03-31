//
//  BookListTableViewController.swift
//  AudioPlayer
//
//  Created by libowen on 2018/3/30.
//  Copyright © 2018年 owen. All rights reserved.
//

import UIKit

class BookListTableViewController: UITableViewController {
    
    // properties
    var books: [Book]!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        // 构造数据
        createData()
        
        // 注册自定义cell（这样tableView才会在dequeue前按你的自定义cell样式初始化cell）
        self.tableView.register(BookCell.self, forCellReuseIdentifier: "BookCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BookCell"
        let cell: BookCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BookCell

        // Configure the cell...
        let book = books[indexPath.row]
        cell.model = book

        return cell
    }
    
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chapterListVC: ChapterListTableViewController = self.storyboard?.instantiateViewController(withIdentifier: ChapterListTableViewController.reuseIdentifier) as! ChapterListTableViewController
        // 传值
        chapterListVC.book = books[indexPath.row]
        self.show(chapterListVC, sender: nil)
    }
 
    
    // MARK: - Helper
    
    func createData() {
        let mcnxsBook = Book.init(name: "明朝那些事儿", author: "当年明月", reader: "王更新", imageString: "image_mcnxs.jpg", count: 268, baseUrlString: "http://www.zgpingshu.com/down/3608/")
        books = [mcnxsBook]
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
