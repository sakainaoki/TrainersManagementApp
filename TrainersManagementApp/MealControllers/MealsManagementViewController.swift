//
//  MealsManagementViewController.swift
//  TrainersManagementApp
//
//  Created by 酒井直輝 on 2021/07/25.
//

import UIKit
import Firebase
import FirebaseFirestore
import SDWebImage
class MealsManagementViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var yearsTextField: UITextField!
    @IBOutlet weak var monthsTextField: UITextField!
    @IBOutlet weak var daysTextField: UITextField!
    @IBOutlet weak var changeDateButton: UIButton!
    
    
    @IBOutlet weak var totalCarbLabel: UILabel!
    @IBOutlet weak var aimCarbLabel: UILabel!
    @IBOutlet weak var totalProteinLabel: UILabel!
    @IBOutlet weak var aimProteinLabel: UILabel!
    @IBOutlet weak var totalFatlabel: UILabel!
    @IBOutlet weak var aimFatLabel: UILabel!
    @IBOutlet weak var totalKcalLabel: UILabel!
    @IBOutlet weak var aimKcalLabel: UILabel!
    
    @IBOutlet weak var brCLabel: UILabel!
    @IBOutlet weak var brPLabel: UILabel!
    @IBOutlet weak var brFLabel: UILabel!
    @IBOutlet weak var brKLabel: UILabel!
    @IBOutlet weak var luCLabel: UILabel!
    @IBOutlet weak var luPLabel: UILabel!
    @IBOutlet weak var luFLabel: UILabel!
    @IBOutlet weak var luKLabel: UILabel!
    @IBOutlet weak var diCLabel: UILabel!
    @IBOutlet weak var diPLabel: UILabel!
    @IBOutlet weak var diFLabel: UILabel!
    @IBOutlet weak var diKLabel: UILabel!
    @IBOutlet weak var snCLabel: UILabel!
    @IBOutlet weak var snPLabel: UILabel!
    @IBOutlet weak var snFLabel: UILabel!
    @IBOutlet weak var snKLabel: UILabel!
    @IBOutlet weak var breakfastImageView: UIImageView!
    @IBOutlet weak var lunchImageView: UIImageView!
    @IBOutlet weak var dinnerImageView: UIImageView!
    @IBOutlet weak var snackImageView: UIImageView!
    @IBOutlet weak var breakfastButton: UIButton!
    @IBOutlet weak var lunchButton: UIButton!
    @IBOutlet weak var dinnerButton: UIButton!
    @IBOutlet weak var snackButton: UIButton!
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    var breakfastArray:[FoodsModel] = []
    var lunchArray:[FoodsModel] = []
    var dinnerArray:[FoodsModel] = []
    var snackArray:[FoodsModel] = []
    var mealsInfoArray:[FoodsModel] = []
    var time = String()
    var storageTime = String()
    var userUid = String()
    var imageURLString = String()
    var yearsPickerView = UIPickerView()
    var monthsPickerView = UIPickerView()
    var daysPickerView = UIPickerView()
    let years = ["2021","2022","2023","2024","2025","2026","2027","2028","2029","2030"]
    let months = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    let days1 = ["01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
    var brImage = String()
    var luImage = String()
    var diImage = String()
    var snImage = String()
    var loadPFC = LoadPFCModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        yearsPickerView.delegate = self
        yearsPickerView.dataSource = self
        monthsPickerView.delegate = self
        monthsPickerView.dataSource = self
        daysPickerView.delegate = self
        daysPickerView.dataSource = self
        messageTextView.delegate = self
        yearsTextField.delegate = self
        monthsTextField.delegate = self
        daysTextField.delegate = self
        yearsPickerView.tag = 1
        monthsPickerView.tag = 2
        daysPickerView.tag = 3
        yearsTextField.backgroundColor = .white
        monthsTextField.backgroundColor = .white
        daysTextField.backgroundColor = .white
        yearsTextField.textColor = .black
        monthsTextField.textColor = .black
        daysTextField.textColor = .black
        yearsTextField.inputView = yearsPickerView
        monthsTextField.inputView = monthsPickerView
        daysTextField.inputView = daysPickerView
        sendButton.layer.cornerRadius = 25
        messageTextView.backgroundColor = .white
        messageTextView.layer.cornerRadius = 10
        sendButton.isEnabled = false
        sendButton.backgroundColor = .lightGray
        changeDateButton.layer.cornerRadius = 10
        userNameLabel.text = (UserDefaults.standard.object(forKey: "userName") as! String)
        userUid = UserDefaults.standard.object(forKey: "userUid") as! String
        
        let date = GetDateModel.getToday()
        yearsTextField.text = String(date.prefix(4))
        daysTextField.text = String(date.suffix(2))
        let startIndex = date.index(date.startIndex, offsetBy: 4)
        let endIndex = date.index(date.startIndex, offsetBy: 6)
        let month = date[startIndex..<endIndex]
        monthsTextField.text = String(month)
        
        sendButtonIsEnabled()
        loadMealsFromFirestore()
        loadImageFromFirebaseStorage()
        
        loadPFC.loadPFCFromFirestore(userUid: userUid, aimCarbLabel: aimCarbLabel, aimProteinLabel: aimProteinLabel, aimFatLabel: aimFatLabel, aimKcalLabel: aimKcalLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    
    @objc func showKeyboard(notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        let sendButtonMaxY = sendButton.frame.maxY
        let distance = sendButtonMaxY - keyboardMinY + 20
        let transform = CGAffineTransform(translationX: 0, y: -distance)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = transform
        })
        
    }

    @objc func hideKeyboard(){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = .identity
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func loadMealsFromFirestore(){
        
        self.breakfastArray.removeAll()
        self.lunchArray.removeAll()
        self.dinnerArray.removeAll()
        self.snackArray.removeAll()
        guard let frontNum = yearsTextField.text else {return}
        guard let backNum = monthsTextField.text else {return}
        guard let documentID = daysTextField.text else {return}
        let collectionID = frontNum + backNum
        Firestore.firestore().collection("users").document(userUid).collection(String(collectionID)).document(String(documentID)).collection("breakfast").getDocuments { SnapshotMetadata, Error in
            if Error != nil {
                print("朝食データの取得に失敗しました。")
                self.breakfastImageView.image = UIImage(named: "image")
                return
            }
            if let snapShotDoc = SnapshotMetadata?.documents {
                var brC:Double = 0
                var brP:Double = 0
                var brF:Double = 0
                var brK:Double = 0
                for doc in snapShotDoc {
                    let data = doc.data()
                    if let foodName = data["foodName"] as? String,let carb = data["carb"] as? String,let protein = data["protein"] as? String,let fat = data["fat"] as? String,let kcal = data["kcal"] as? String{
                        let food = FoodsModel(foodName: foodName, carb: carb, protein: protein, fat: fat,kcal: kcal)
                        self.breakfastArray.append(food)
                        brC += Double(carb)!
                        brP += Double(protein)!
                        brF += Double(fat)!
                        brK += Double(kcal)!
                    }
                }
                self.brCLabel.text = String(brC)
                self.brPLabel.text = String(brP)
                self.brFLabel.text = String(brF)
                self.brKLabel.text = String(brK)
                
                Firestore.firestore().collection("users").document(self.userUid).collection(String(collectionID)).document(String(documentID)).collection("lunch").getDocuments { SnapshotMetadata, Error in
                    if Error != nil {
                        print("昼食データの取得に失敗しました。")
                        self.lunchImageView.image = UIImage(named: "image")
                        return
                    }
                    
                    if let snapShotDoc = SnapshotMetadata?.documents {
                        var luC:Double = 0
                        var luP:Double = 0
                        var luF:Double = 0
                        var luK:Double = 0
                        for doc in snapShotDoc {
                            let data = doc.data()
                            if let foodName = data["foodName"] as? String,let carb = data["carb"] as? String,let protein = data["protein"] as? String,let fat = data["fat"] as? String,let kcal = data["kcal"] as? String{
                                let food = FoodsModel(foodName: foodName, carb: carb, protein: protein, fat: fat,kcal: kcal)
                                self.lunchArray.append(food)
                                luC += Double(carb)!
                                luP += Double(protein)!
                                luF += Double(fat)!
                                luK += Double(kcal)!
                            }
                        }
                        self.luCLabel.text = String(luC)
                        self.luPLabel.text = String(luP)
                        self.luFLabel.text = String(luF)
                        self.luKLabel.text = String(luK)
                        Firestore.firestore().collection("users").document(self.userUid).collection(String(collectionID)).document(String(documentID)).collection("dinner").getDocuments { SnapshotMetadata, Error in
                            if Error != nil {
                                print("夕食データの取得に失敗しました。")
                                self.dinnerImageView.image = UIImage(named: "image")
                                return
                            }
                            if let snapShotDoc = SnapshotMetadata?.documents {
                                var diC:Double = 0
                                var diP:Double = 0
                                var diF:Double = 0
                                var diK:Double = 0
                                for doc in snapShotDoc {
                                    let data = doc.data()
                                    if let foodName = data["foodName"] as? String,let carb = data["carb"] as? String,let protein = data["protein"] as? String,let fat = data["fat"] as? String,let kcal = data["kcal"] as? String{
                                        let food = FoodsModel(foodName: foodName, carb: carb, protein: protein, fat: fat,kcal: kcal)
                                        self.dinnerArray.append(food)
                                        diC += Double(carb)!
                                        diP += Double(protein)!
                                        diF += Double(fat)!
                                        diK += Double(kcal)!
                                    }
                                }
                                
                                self.diCLabel.text = String(diC)
                                self.diPLabel.text = String(diP)
                                self.diFLabel.text = String(diF)
                                self.diKLabel.text = String(diK)
                                Firestore.firestore().collection("users").document(self.userUid).collection(String(collectionID)).document(String(documentID)).collection("snack").getDocuments { SnapshotMetadata, Error in
                                    if Error != nil {
                                        print("間食データの取得に失敗しました。")
                                        self.snackImageView.image = UIImage(named: "image")
                                        return
                                    }
                                    if let snapShotDoc = SnapshotMetadata?.documents {
                                        var snC:Double = 0
                                        var snP:Double = 0
                                        var snF:Double = 0
                                        var snK:Double = 0
                                        for doc in snapShotDoc {
                                            let data = doc.data()
                                            if let foodName = data["foodName"] as? String,let carb = data["carb"] as? String,let protein = data["protein"] as? String,let fat = data["fat"] as? String,let kcal = data["kcal"] as? String{
                                                let food = FoodsModel(foodName: foodName, carb: carb, protein: protein, fat: fat,kcal: kcal)
                                                self.snackArray.append(food)
                                                snC += Double(carb)!
                                                snP += Double(protein)!
                                                snF += Double(fat)!
                                                snK += Double(kcal)!
                                            }
                                        }
                                       
                                        self.snCLabel.text = String(snC)
                                        self.snPLabel.text = String(snP)
                                        self.snFLabel.text = String(snF)
                                        self.snKLabel.text = String(snK)
                                        self.calcPFC()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func loadImageFromFirebaseStorage(){
        guard let yearsNum = yearsTextField.text else {return}
        guard let monthsNum = monthsTextField.text else {return}
        guard let daysNum = daysTextField.text else {return}
        let date = yearsNum + monthsNum + daysNum

        Storage.storage().reference().child("mealImage").child(userUid).child(date).child("\(userUid + "breakfast" + date)").downloadURL { URL, Error in
            if Error != nil{
                print("画像の取得に失敗しました。",Error.debugDescription)
                return
        }
            if let imageString = URL?.absoluteURL {
                self.breakfastImageView.sd_setImage(with: imageString, completed: nil)
            }
        }
        DispatchQueue.main.async {
            Storage.storage().reference().child("mealImage").child(self.userUid).child(date).child("\(self.userUid + "lunch" + date)").downloadURL { URL, Error in
                if Error != nil{
                    print("画像の取得に失敗しました。",Error.debugDescription)
                    return
            }
                if let imageString = URL?.absoluteURL {
                    self.lunchImageView.sd_setImage(with: imageString, completed: nil)
                }
            }
        }
        DispatchQueue.main.async {
            Storage.storage().reference().child("mealImage").child(self.userUid).child(date).child("\(self.userUid + "dinner" + date)").downloadURL { URL, Error in
                if Error != nil{
                    print("画像の取得に失敗しました。",Error.debugDescription)
                    return
            }
                if let imageString = URL?.absoluteURL {
                    self.dinnerImageView.sd_setImage(with: imageString, completed: nil)
                }
            }
        }
        DispatchQueue.main.async {
            Storage.storage().reference().child("mealImage").child(self.userUid).child(date).child("\(self.userUid + "snack" + date)").downloadURL { URL, Error in
                if Error != nil{
                    print("画像の取得に失敗しました。",Error.debugDescription)
                    return
            }
                if let imageString = URL?.absoluteURL {
                    self.snackImageView.sd_setImage(with: imageString, completed: nil)
                }
            }
        }
    }
    
    private func calcPFC(){
        
        let totalC = Double(brCLabel.text!)! + Double(luCLabel.text!)! + Double(diCLabel.text!)! + Double(snCLabel.text!)!
        totalCarbLabel.text = String(totalC)
        let totalP = Double(brPLabel.text!)! + Double(luPLabel.text!)! + Double(diPLabel.text!)! + Double(snPLabel.text!)!
        totalProteinLabel.text = String(totalP)
        let totalF = Double(brFLabel.text!)! + Double(luFLabel.text!)! + Double(diFLabel.text!)! + Double(snFLabel.text!)!
        totalFatlabel.text = String(totalF)
        let totalK = Double(brKLabel.text!)! + Double(luKLabel.text!)! + Double(diKLabel.text!)! + Double(snKLabel.text!)!
        totalKcalLabel.text = String(totalK)
    }
    

    func changeIsEnabled(){
        if monthsTextField.text == "04" && daysTextField.text == "31"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            print("04")
        }else if monthsTextField.text == "06" && daysTextField.text == "31"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            
        }else if monthsTextField.text == "09" && daysTextField.text == "31"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            
        }else if monthsTextField.text == "11" && daysTextField.text == "31"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            
        }else if monthsTextField.text == "02" && daysTextField.text == "30"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            
        }else if monthsTextField.text == "02" && daysTextField.text == "31"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            
        }else{
            changeDateButton.isEnabled = true
            changeDateButton.backgroundColor = UIColor.rgb(red: 64, green: 190, blue: 234)
            
        }
    }
    
    @IBAction func tappedChangeDateButton(_ sender: Any) {
        breakfastImageView.image = UIImage(named: "image")
        lunchImageView.image = UIImage(named: "image")
        dinnerImageView.image = UIImage(named: "image")
        snackImageView.image = UIImage(named: "image")
        
        loadMealsFromFirestore()
        loadImageFromFirebaseStorage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mealsInfoVC = segue.destination as! MealInfoViewController
        mealsInfoVC.mealsArray = mealsInfoArray
        mealsInfoVC.time = time
        let years = "\(yearsTextField.text!)"
        let months = "\(monthsTextField.text!)"
        let days = "\(daysTextField.text!)"
        let date = years + months + days
        mealsInfoVC.date = date
        mealsInfoVC.storageTime = storageTime
    }
    
   
    @IBAction func tappedMealsInfoButton(_ sender: Any) {
        if let button = sender as? UIButton {
            if button.tag == 1 {
                mealsInfoArray = breakfastArray
                time = "朝食"
                storageTime = "breakfast"
            }else if button.tag == 2 {
                mealsInfoArray = lunchArray
                time = "昼食"
                storageTime = "lunch"
            }else if button.tag == 3 {
                mealsInfoArray = dinnerArray
                time = "夕食"
                storageTime = "dinner"
            }else if button.tag == 4 {
                mealsInfoArray = snackArray
                time = "間食"
                storageTime = "snack"
            }
        }
        
        performSegue(withIdentifier: "mealsInfo", sender: nil)
        
    }
    private func sendMessageToFirestore(){
        let date = GetDateModel.getToday()
        let time = GetDateModel.getTimeDate()
        let dayAndTime = GetDateModel.getTodayAndTimeDate()
        let read = false
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let message = messageTextView.text else {return}
        let advice = "【お食事評価】\n\(message)"
        let messageDocData = ["uid":uid,
                              "message": advice,
                              "date":date,
                              "time":time,
                              "read":read,
                              "dayAndTime":dayAndTime,
                              "timeStamp":Timestamp()] as [String : Any]
        Firestore.firestore().collection("users").document(userUid).collection("messages").document(String(dayAndTime)).setData(messageDocData) { Error in
            if Error != nil{
                print("messageの保存に失敗しました。",Error.debugDescription)
                return
            }
           
            DispatchQueue.main.async {
                
                self.messageTextView.text = ""
                self.messageTextView.resignFirstResponder()
            }
        }
    }
    private func sendButtonIsEnabled(){
        let messageIsEmpty = messageTextView.text.isEmpty ?? true
        if messageIsEmpty {
            sendButton.isEnabled = false
            sendButton.backgroundColor = .lightGray
        }else{
            sendButton.isEnabled = true
            sendButton.backgroundColor = .red
        }
    }
    
    
    @IBAction func tappedSendButton(_ sender: Any) {
        sendMessageToFirestore()
    }
    
    
}

extension MealsManagementViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
       sendButtonIsEnabled()
    }
}

extension MealsManagementViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var pickerViewTitle = String()
        if pickerView.tag == 1 {
            pickerViewTitle = years[row]
            
        } else if pickerView.tag == 2 {
            pickerViewTitle =  months[row]
            
        } else if pickerView.tag == 3 {
            pickerViewTitle = days1[row]
            
        }
        return pickerViewTitle
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            yearsTextField.text = years[row]
            yearsTextField.resignFirstResponder()
        } else if pickerView.tag == 2 {
            monthsTextField.text = months[row]
            monthsTextField.resignFirstResponder()
            
        } else if pickerView.tag == 3 {
            daysTextField.text = days1[row]
            daysTextField.resignFirstResponder()
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = Int()
        if pickerView.tag == 1 {
            count = years.count
        } else if pickerView.tag == 2 {
            count = months.count
        } else if pickerView.tag == 3 {
            count = days1.count
        }
        return count
    }
    
    
}
extension MealsManagementViewController:UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        changeIsEnabled()
        
    }
}

