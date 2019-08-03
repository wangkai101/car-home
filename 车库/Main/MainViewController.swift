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
        //监听通知
        setupNotification()
        
        
        
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

//MARK:-监听通知
extension MainViewController {
    private func setupNotification() {
        
        //从addCar获取添加到的car信息
        NotificationCenter.default.addObserver(self, selector: #selector(showModel), name: NSNotification.Name(rawValue: modelNotification), object: nil)
        
        //从详情页获取删除点击事件
        NotificationCenter.default.addObserver(self, selector: #selector(deleteRow), name: NSNotification.Name(DetailNote), object: nil)
        
        //从详情页获得修改信息
        NotificationCenter.default.addObserver(self, selector: #selector(changeRow), name: NSNotification.Name(ChangeNote), object: nil)
    }
}

//MARK:-通知方法
extension MainViewController {
    //添加数据
    @objc private func showModel(note : NSNotification) {
        
        let modelNumber = note.userInfo!["number"] as! Int
        let modelBrand = note.userInfo!["brand"] as! String
        let modelName = note.userInfo!["name"] as! String
        let image = note.userInfo!["image"] as! UIImage
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        car = CarsMO(context: appDelegate.persistentContainer.viewContext)
        car.brand = modelBrand
        car.image = image.jpegData(compressionQuality: 0.7)
        car.name = modelName
        car.number = Int16(modelNumber)
        
        print("正在保存")
        appDelegate.saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
    //删除
    @objc private func deleteRow() {
        //cars.remove(at: tableView.indexPathForSelectedRow!.row)
        
        let indexPath = tableView.indexPathForSelectedRow!
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        context.delete(self.fc.object(at: indexPath))
        appDelegate.saveContext()

    }
    
    //修改
    @objc private func changeRow(note : NSNotification) {
        let number = note.userInfo!["number"] as! Int
        let brand = note.userInfo!["brand"] as! String
        let name = note.userInfo!["name"] as! String
      
        let dict = cars[tableView.indexPathForSelectedRow!.row]
        dict.number = Int16(number)
        dict.brand = brand
        dict.name = name
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
    }
    
    //按条件筛选
    private func searchFilter(text : String) {
        
        let brandResults = cars.filter { (Car) -> Bool in
            return (Car.brand?.localizedCaseInsensitiveContains(text))!
        }
        
        let nameResults = cars.filter({ (Car) -> Bool in
            return (Car.name?.localizedCaseInsensitiveContains(text))!
        })

        let numberResult = cars.filter({ (Car) -> Bool in
            return (String(Car.number).localizedCaseInsensitiveContains(text))
        })
        
        searchResults = brandResults + nameResults + numberResult
    }
    
    //取数据
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
}

//MARK:- 遵守UITableview数据源协议和代理
extension MainViewController {
    //MARK:- 遵守uitableView数据源协议
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchCtr.isActive ? searchResults.count : cars.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CardCell, for: indexPath) as! MainViewCell
        
        let car = searchCtr.isActive ? searchResults[indexPath.row] : cars[indexPath.row]
        
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
        
        destination.car = searchCtr.isActive ? searchResults[row] : cars[row]
        destination.isSearchActive = searchCtr.isActive
        
    }
}
}

//MARK:- 遵守UISearchResultsUpdating代理
extension MainViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if var text = searchController.searchBar.text {
            text = text.trimmingCharacters(in: .whitespaces)
            searchFilter(text: text)
            tableView.reloadData()
        }
    }
    
    
}





////MARK:- 编解码
//extension MainViewController {
////    //编码
////    func saveToJson() {
////        let coder = JSONEncoder()
////        do {
////            let data = try coder.encode(cars)
////            let saveUrl = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("cars.json")
////
////            try data.write(to: saveUrl)
////            print("保存成功：",saveUrl)
////        } catch  {
////            print("编码错误:",error)
////        }
////    }
//
////    //解码
////    func loadJson() {
////        let coder = JSONDecoder()
////
////        do {
////            let url = Bundle.main.url(forResource: "cars", withExtension: "json")!
////            let data = try Data(contentsOf: url)
////            cars = try coder.decode([Car].self, from: data)
////        } catch  {
////            print("解码错误:",error)
////        }
////    }
//}
