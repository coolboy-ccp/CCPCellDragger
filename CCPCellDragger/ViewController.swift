//
//  ViewController.swift
//  CCPCellDragger
//
//  Created by 储诚鹏 on 2019/1/11.
//  Copyright © 2019 储诚鹏. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var listTable: UITableView!
    private var datas = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTable.register(UITableViewCell.self, forCellReuseIdentifier: "CCPRefresherCell")
        datas.append(contentsOf: oneGroupData())
        listTable.ccp.enable(effectType: .hover, datas: datas) { (data) in
            self.datas = data as! [String]
        }
    }
    
    private func oneGroupData() -> [String] {
        var oneGroup = [String]()
        for i in 0 ..< 15 {
            oneGroup.append("CCPCellDragger_\(i)")
        }
        return oneGroup
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var resutCell = UITableViewCell()
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CCPRefresherCell") {
            resutCell = cell
        }
        resutCell.textLabel?.text = datas[indexPath.row]
        return resutCell
    }


}

