//
//  MainViewController.swift
//  车库
//
//  Created by Mr wngkai on 2019/7/28.
//  Copyright © 2019 Mr wngkai. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UITableViewController {
    
    var cars : [CarsMO] =  []
    var searchResults : [CarsMO] = []
    var car : CarsMO!
    var fc : NSFetchedResultsController<CarsMO>!
    
    //MARK:- 懒加载属性
    private lazy var nilLabel : UILabel = UILabel()
    private lazy var searchCtr : UISearchController = UISearchController(searchResultsController: nil)
    
    //MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //搜索框设置
        searchCtr.searchResultsUpdater = self
        tableView.tableHeaderView = searchCtr.searchBar
        searchCtr.dimsBackgroundDuringPresentation = false
        searchCtr.searchBar.searchBarStyle = .minimal
        searchCtr.searchBar.placeholder = "输入关键词进行搜索"
        self.definesPresentationContext = true
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //请求所有数据
        newfetchAllData()
        
        tableView.reloadData()
        
        //设置提示
        setupNilLabelTitle()
        
        
    }
    
    //移除通知
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- 设置nilLabel提示
extension MainViewController {
    private func setupNilLabelTitle() {
        
        view.addSubview(nilLabel)
        
        nilLabel.frame = CGRect(x: 0, y: UIScreen.main.bounds.height / 3, width: UIScreen.main.bounds.width, height: 50)
        nilLabel.text = "请先添加车型"
        nilLabel.textAlignment = .center
        
        if cars.count != 0 {
            nilLabel.isHidden = true
        }
    }
}



//MARK:-方法
extension MainViewController {
    //获取所有数据
    private func newfetchAllData() {
        //请求结果类型是CarsMO
        let request: NSFetchRequest<CarsMO> = CarsMO.fetchRequest()
        //NSSortDescriptor指定请求结果如何排序
        let sd = NSSortDescriptor(key: "brand", ascending: true)
        //let sd2 = NSSortDescriptor(key: "number", ascending: true)
        request.sortDescriptors = [sd]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //NSFetchedResultsController初始化，并指定代理
        fc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fc.delegate = self
        
        //执行查询，把结果存到数组
        do {
            try fc.performFetch()
            if let object = fc.fetchedObjects {
                cars = object
            }
        } catch  {
            print(error)
        }
    }
    
    //获取特定数据
    private func fetchSomeData(name : String) {
        //请求结果类型是CarsMO
        let request: NSFetchRequest<CarsMO> = CarsMO.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        //NSSortDescriptor指定请求结果如何排序
        let sd = NSSortDescriptor(key: "brand", ascending: true)
        request.sortDescriptors = [sd]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //NSFetchedResultsController初始化，并指定代理
        fc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fc.delegate = self
        
        //执行查询，把结果存到数组
        do {
            try fc.performFetch()
            if let object = fc.fetchedObjects {
                cars = object
            }
        } catch  {
            print(error)
        }
    }
}

//MARK:- 遵守UITableview数据源协议和代理
extension MainViewController {
    //MARK:- 遵守uitableView数据源协议
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return searchCtr.isActive ? searchResults.count : cars.count
        return cars.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CardCell, for: indexPath) as! MainViewCell
        
        //let car = searchCtr.isActive ? searchResults[indexPath.row] : cars[indexPath.row]
        let car = cars[indexPath.row]
        
        
        cell.nameLabel.text = car.name
        cell.brandLabel.text = car.brand
        cell.numberLabel.text = String(car.number)
        
        cell.backImageView.image = UIImage(data: car.image!)
        
        return cell
    }
    
    //判断单元格是否可以编辑
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !searchCtr.isActive
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        searchCtr.dismiss(animated: true, completion: nil)
        //        tableView.reloadData()
        //        if searchCtr.isActive {
        //            searchResults.remove(at: tableView.indexPathForSelectedRow!.row)
        //
        //        }
        
    }
    
    
    //实现左划
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //数量加
        let addAction = UIContextualAction(style: .normal, title: "+") { (_, _, finish) in
            self.cars[indexPath.row].number += 1
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.saveContext()
            
            finish(false)
            
        }
        
        addAction.backgroundColor = UIColor.blue
        
        return UISwipeActionsConfiguration(actions: [addAction])
    }
    //实现右划
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //数量减
        let delAction = UIContextualAction(style: .destructive, title: "-") { (_, _, finish) in
            if self.cars[indexPath.row].number > 0 {
                self.cars[indexPath.row].number -= 1
            }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.saveContext()
            
            finish(false)
            //tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [delAction])
        
    }
}

//MARK:- 遵守coreData的协议
//NSFetchedResultsControllerDelegate此协议提供数据变化时通知其代理的方法
extension MainViewController : NSFetchedResultsControllerDelegate {
    
    //即将改变
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    //已经改变
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    //正在变化
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        default:
            tableView.reloadData()
        }
        
        //数据已经发生变化，同步到数组
        if let objects = controller.fetchedObjects {
            cars = objects as! [CarsMO]
        }
    }
    
    
}

// MARK: - Navigation 传值
extension MainViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCarsDetail" {
            let row = tableView.indexPathForSelectedRow!.row
            let destination = segue.destination as! DetailController
            
            //destination.car = searchCtr.isActive ? searchResults[row] : cars[row]
            destination.car = cars[row]
            
            
            
            
        }
    }
}

//MARK:- 遵守UISearchResultsUpdating代理
extension MainViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        if searchCtr.isActive {
            if var text = searchController.searchBar.text {
                text = text.trimmingCharacters(in: .whitespaces)
                // searchFilter(text: text)
                fetchSomeData(name: text)
                tableView.reloadData()
            }
            
        } else {
            newfetchAllData()
            tableView.reloadData()
        }
        
    }
    
    
}





