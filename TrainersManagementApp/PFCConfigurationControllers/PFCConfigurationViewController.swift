//
//  PFCConfigurationViewController.swift
//  TrainersManagementApp
//
//  Created by 酒井直輝 on 2021/08/10.
//

import UIKit
import Firebase
class PFCConfigurationViewController: UIViewController {
    @IBOutlet weak var kcalTextField: UITextField!
    @IBOutlet weak var carbTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    @IBOutlet weak var configurationButton: UIButton!
    var userUid = UserDefaults.standard.object(forKey: "userUid") as! String
    let alertSystem = AlertSystem()
    override func viewDidLoad() {
        super.viewDidLoad()
        kcalTextField.delegate = self
        carbTextField.delegate = self
        proteinTextField.delegate = self
        fatTextField.delegate = self
        buttonIsEnabled()
        configurationButton.layer.cornerRadius = 15
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func buttonIsEnabled(){
        if kcalTextField.text?.isEmpty == true || carbTextField.text?.isEmpty == true || proteinTextField.text?.isEmpty == true || fatTextField.text?.isEmpty == true {
            configurationButton.isEnabled = false
            configurationButton.backgroundColor = UIColor.rgb(red: 169, green: 169, blue: 169)
        }else{
            configurationButton.isEnabled = true
            configurationButton.backgroundColor = UIColor.rgb(red: 0, green: 191, blue: 255)
        }
    }
    private func sendPFCTofirestore(){
        guard let kcal = kcalTextField.text else {return}
        guard let carb = carbTextField.text else {return}
        guard let protein = proteinTextField.text else {return}
        guard let fat = fatTextField.text else {return}
        let docData = ["kcal":kcal,"carb":carb,"protein":protein,"fat":fat]
        Firestore.firestore().collection("users").document(userUid).collection("PFC").document("targetPFC").setData(docData) { Error in
            if Error != nil{
                print("PFCの保存に失敗しました。",Error.debugDescription)
                return
            }
            self.kcalTextField.text = ""
            self.carbTextField.text = ""
            self.proteinTextField.text = ""
            self.fatTextField.text = ""
            self.configurationButton.isEnabled = false
            self.configurationButton.backgroundColor = UIColor.rgb(red: 169, green: 169, blue: 169)
            self.alertSystem.showAlert(title: "設定完了", message: "目標PFCの設定が完了しました。", buttonTitle: "OK!", viewController: self)
            
        }
    }
    
    @IBAction func tappedConfigurationButton(_ sender: Any) {
        sendPFCTofirestore()
        self.view.endEditing(true)
    }
    
}
extension PFCConfigurationViewController:UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        buttonIsEnabled()
    }
    
}
