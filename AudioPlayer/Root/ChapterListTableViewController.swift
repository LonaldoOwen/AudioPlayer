//
//  ChapterListTableViewController.swift
//  AudioPlayer
//
//  Created by libowen on 2018/3/30.
//  Copyright © 2018年 owen. All rights reserved.
//

import UIKit

// Global variables and const goes there!



class ChapterListTableViewController: UITableViewController {
    
    static let reuseIdentifier = "ChapterListVC"
    
    // properties
    var book: Book!
    var chapters: [Chapter]!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // create data
        createData()
        
        // register ChapterListCell
        //self.tableView.register(ChapterListCell.self, forCellReuseIdentifier: ChapterListCell.reuseIdentifier)
        self.tableView.register(UINib.init(nibName: "ChapterListCell", bundle: nil), forCellReuseIdentifier: ChapterListCell.reuseIdentifier)
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
        return chapters.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChapterListCell = tableView.dequeueReusableCell(withIdentifier: ChapterListCell.reuseIdentifier, for: indexPath) as! ChapterListCell

        // Configure the cell...
        let chapter = chapters[indexPath.row]
        cell.model = chapter

        return cell
    }
    
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parserVC: ParseViewController = self.storyboard?.instantiateViewController(withIdentifier: ParseViewController.reuseIdentifier) as! ParseViewController
        parserVC.book = book
        parserVC.chapter = chapters[indexPath.row]
        self.show(parserVC, sender: nil)
    }

    
    // MARK: -Helper
    
    func createData() {
        var tempChapters: [Chapter] = []
        for index in 1...book.count {
            let chapter = Chapter.init(index: "\(index)",
                                       title: book.name + "_" + "\(index)",
                                       reader: book.reader,
                                       duration: "03:45",
                                       urlString: book.baseUrlString + "\(index)" + ".html")
            tempChapters.append(chapter)
        }
        chapters = tempChapters
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
