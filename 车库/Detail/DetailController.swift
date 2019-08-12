//
//  DetailController.swift
//  车库
//
//  Created by Mr wngkai on 2019/7/29.
//  Copyright © 2019 Mr wngkai. All rights reserved.
//

import UIKit
import CoreData

class DetailController: UITableViewController {
    
    var car : CarsMO?
    var image : UIImage?
    
    
    private lazy var alertVC : UIAlertController = UIAlertController(title: "", message: "确定删除此车型吗", preferredStyle: .alert)
    
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var nameTextFiled: UITextField!
    @IBOutlet weak var brandTextFiled: UITextField!
    @IBOutlet weak var numberTextFiled: UITextField!
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var remarksText: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
}
//MARK:- 设置ui
extension DetailController {
    private func setupUI() {
        
        headerImageView.image = UIImage(data: car!.image!)
        nameTextFiled.text = car?.name
        brandTextFiled.text = car?.brand
        numberTextFiled.text = car?.number.description
        remarksText.text = car?.remarks
        
        navigationItem.largeTitleDisplayMode = .never
        
        //设置提示框
        let okAction = UIAlertAction(title: "确定", style: .destructive) { (UIAlertAction) in
            
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
    }
}

//MARK:- 监听事件
extension DetailController {
    @IBAction func delBtnClick() {
        
        present(alertVC, animated: true, completion: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        context.delete(car!)
        appDelegate.saveContext()
        
        
        
    }
    
    @IBAction func saveBtnClick() {
        
        
        car!.brand = brandTextFiled.text
        car!.name = nameTextFiled.text
        let number = Int(numberTextFiled.text!) ?? 0
        car!.number = Int16(number)
        car!.remarks = remarksText.text
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
        
        
        
        
        
        navigationController?.popViewController(animated: true)
        
    }
    
}







