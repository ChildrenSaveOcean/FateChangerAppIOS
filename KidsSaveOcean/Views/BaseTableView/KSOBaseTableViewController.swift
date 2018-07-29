//
//  KSOBaseTableViewController.swift
//  KidsSaveOcean
//
//  Created by Maria Soboleva on 6/4/18.
//  Copyright © 2018 KidsSaveOcean. All rights reserved.
//

import UIKit

fileprivate let kCellIdentefire = "baseTableViewCellIdentefier"

class KSOBaseTableViewController: UITableViewController {
    
    var tableViewData: KSODataArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.backgroundGray
        tableView.isScrollEnabled = true
        tableView.alwaysBounceVertical = false
        tableView.isUserInteractionEnabled = true
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.backgroundGray
        tableView.showsVerticalScrollIndicator = false
        
        tableView.rowHeight = 72.2
        
        tableView.dataSource = self
        tableView.delegate   = self
        
        tableView.register(KSOBaseTableViewCell.self, forCellReuseIdentifier: kCellIdentefire)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createCell(at: indexPath)
    }
    
    func createCell(at indexPath:IndexPath) -> KSOBaseTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentefire, for: indexPath)  as! KSOBaseTableViewCell
        
        // TODO: make an exception about the data does not set up
        let cellData = BaseTableViewData(dictionary: tableViewData[indexPath.row])
        cell.tableViewTitle.text = cellData?.title
        cell.tableViewSubTitle.text = cellData?.subTitle
        
        if (cellData?.image != nil) {
            cell.tableViewIcon.image = cellData?.image
        } else {
            cell.tableViewIcon.image = UIImage(color:UIColor.lightGray)
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - make last row in section corners rounded
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.separatorInset = UIEdgeInsetsMake(0, (cell as! KSOBaseTableViewCell).tableViewTitle.frame.origin.x, 0, 5)
        
        let rowsCount = tableView.numberOfRows(inSection: indexPath.section)
        let cornerRadius: CGFloat = StandardViewGap
        if indexPath.row == rowsCount-1 {
            
            cell.clipsToBounds = true
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        cell.layoutIfNeeded()
        (cell as! KSOBaseTableViewCell).roundIcon()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = KSOBaseTableHeaderView(frame: CGRect(x: 0, y: 0, width:tableView.frame.width, height: StandardTableHeaderHeight))
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return StandardTableHeaderHeight
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return StandardViewGap
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

