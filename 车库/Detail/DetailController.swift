//
//  DetailController.swift
//  车库
//
//  Created by Mr wngkai on 2019/7/29.
//  Copyright © 2019 Mr wngkai. All rights reserved.
//

import UIKit

class DetailController: UITableViewController {

    var car : CarsMO?
    var image : UIImage?
    var isSearchActive : Bool = false
    
    private lazy var alertVC : UIAlertController = UIAlertController(title: "", message: "确定删除此车型吗", preferredStyle: .alert)
    
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var nameTextFiled: UITextField!
    @IBOutlet weak var brandTextFiled: UITextField!
    @IBOutlet weak var numberTextFiled: UITextField!
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
       // hideBtn(isSearchActive: isSearchActive)
    }

    override func viewDidAppear(_ animated: Bool) {
  
    }
    
//    private func hideBtn(isSearchActive : Bool) {
//        if isSearchActive {
//            delBtn.isHidden = true
//            saveBtn.isHidden = true
//            nameTextFiled.isEnabled = false
//            brandTextFiled.isEnabled = false
//            numberTextFiled.isEnabled = false
//
//        }
//    }
}
    //MARK:- 设置ui
    extension DetailController {
        private func setupUI() {
            
            headerImageView.image = UIImage(data: car!.image!)
            nameTextFiled.text = car?.name
            brandTextFiled.text = car?.brand 
            numberTextFiled.text = car?.number.description
            
            navigationItem.largeTitleDisplayMode = .never
            
            //设置提示框
            let okAction = UIAlertAction(title: "确定", style: .destructive) { (UIAlertAction) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: DetailNote), object: nil)
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
    }
    
    @IBAction func saveBtnClick() {
        
        let userInfo = ["number": Int(numberTextFiled.text!)!, "brand": brandTextFiled.text!, "name" : nameTextFiled.text!] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ChangeNote), object: nil, userInfo: userInfo)
        navigationController?.popViewController(animated: true)
    }
    
}
    
    
 

   


