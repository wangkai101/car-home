//
//  AddCarController.swift
//  车库
//
//  Created by Mr wngkai on 2019/7/29.
//  Copyright © 2019 Mr wngkai. All rights reserved.
//

import UIKit

class AddCarController: UITableViewController {
    var pickViewTitle = "雅迪"
    var brand = ["雅迪","福田","其他"]
    
    var car : CarsMO?
    
    
    
    


    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var numberText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // loadJson()
        
        
       
    }


}

//MARK:- 监听事件
extension AddCarController {
    //步进器的转换
    @IBAction func tapStepper(_ sender: UIStepper) {
        numberText.text = Int(exactly: sender.value)?.description
        
        
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //实现保存按钮
    @IBAction func caveBtnClick(_ sender: Any) {
        
        let userInfo = ["number": Int(numberText.text!)!, "brand": pickViewTitle, "name" : nameText.text!, "image" : bgImageView.image!] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: modelNotification), object: nil, userInfo: userInfo)
        
    }
    
    //弹出照片选择
    private func selectPhoto() {
        //创建一个弹出表单
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "从图库中选择", style: .default) { (_) in
            self.addPhotoClick(st: .photoLibrary)
        }
        
        let takePhotoAction = UIAlertAction(title: "拍照", style: .default) { (_) in
            self.addPhotoClick(st: .camera)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            
        }
        
        actionSheet.addAction(photoAction)
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func addPhotoClick(st : UIImagePickerController.SourceType) {
        //判断数据源是否可用
        if !UIImagePickerController.isSourceTypeAvailable(st) {
            return
        }
        
        //创建照片选择控制器
        let ipc = UIImagePickerController()
        
        //设置照片源
        ipc.sourceType = st
        
        //设置代理
        ipc.delegate = self
        
        //弹出选择照片的控制器
        present(ipc, animated: true, completion: nil)
        
    }
}


//MARK:-UIImagePickerController的代理方法
extension AddCarController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //print(info)
        //获取选中的照片
        let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) ?? UIImage(named: "compose_toolbar_picture")!
        
//        //展示照片
        bgImageView.image = image

        
//
//        //将数组赋值给collectionView，让其展示数据
//        picPickerView.images = images
//
//        //退出选中照片控制器
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- 遵守pickView数据源协议代理
extension AddCarController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return brand[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickViewTitle = brand[row]
        
    }
}


//MARK:- 遵守UITableViewController代理
extension AddCarController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectPhoto()
        }
    }
    

}


////MARK:- json解码
//extension AddCarController {
//    private func loadJson() {
//        let coder = JSONDecoder()
//
//        do {
//            let url = Bundle.main.url(forResource: "carsBrand", withExtension: ".json")!
//            let data = try Data(contentsOf: url)
//
//            brand = try coder.decode(CarsBrand.self, from: data)
//            print("载入成功")
//        } catch {
//            print(error)
//        }
//
//
//    }
//}
