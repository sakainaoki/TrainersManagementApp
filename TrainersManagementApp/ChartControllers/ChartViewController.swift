//
//  ChartViewController.swift
//  TrainersManagementApp
//
//  Created by 酒井直輝 on 2021/08/09.
//

import UIKit
import Charts
import Firebase

class ChartViewController: UIViewController {
    @IBOutlet weak var targetWeightLabel: UILabel!
    @IBOutlet weak var nowWeightLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    @IBOutlet weak var yearsTextField: UITextField!
    @IBOutlet weak var monthsTextField: UITextField!
    @IBOutlet weak var changeMonthButton: UIButton!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var configuretionButton: UIButton!
    @IBOutlet weak var setTargetWeightTextField: UITextField!
    
    var userUid = UserDefaults.standard.object(forKey: "userUid") as! String
    var yearsPickerView = UIPickerView()
    var monthsPickerView = UIPickerView()
    let years = ["2021","2022","2023","2024","2025","2026","2027","2028","2029","2030","2031"]
    let months = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    var weightModel = WeightModel()
    let date = GetDateModel.getToday()
    var chartArray:[PersonalData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        yearsPickerView.delegate = self
        yearsPickerView.dataSource = self
        monthsPickerView.delegate = self
        monthsPickerView.dataSource = self
        weightModel.getDataProtocol = self
        setTargetWeightTextField.delegate = self
        yearsTextField.inputView = yearsPickerView
        monthsTextField.inputView = monthsPickerView
        yearsPickerView.tag = 1
        monthsPickerView.tag = 2
        yearsTextField.text = String(date.prefix(4))
        let startIndex = date.index(date.startIndex, offsetBy: 4)
        let endIndex = date.index(date.startIndex, offsetBy: 6)
        let month = date[startIndex..<endIndex]
        monthsTextField.text = String(month)
        weightModel.loadWeightFromFirestore(userUid: userUid, year: yearsTextField.text!, month: monthsTextField.text!)
        weightModel.loadTargetWeight(userUid: userUid)
        calcWeight()
        buttonIsEnabled()
        configuretionButton.layer.cornerRadius = 25
        changeMonthButton.layer.cornerRadius = 10
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func showKeyboard(notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        let configuretionButtonMaxY = configuretionButton.frame.maxY
        let distance = configuretionButtonMaxY - keyboardMinY + 20
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
    
    func buttonIsEnabled(){
        if setTargetWeightTextField.text?.isEmpty == true{
            configuretionButton.isEnabled = false
            configuretionButton.backgroundColor = UIColor.rgb(red: 169, green: 169, blue: 169)
        }else{
            configuretionButton.isEnabled = true
            configuretionButton.backgroundColor = UIColor.rgb(red: 48, green: 209, blue: 88)
        }
    }
    
    
    
    func calcWeight() {
        guard let targetWeight = UserDefaults.standard.object(forKey: "\(userUid)targetWeight") else {return}
        guard let nowWeight = UserDefaults.standard.object(forKey: "\(userUid)nowWeight") else {return}
        let difference = Float(targetWeight as! Substring)! - Float(nowWeight as! Substring)!
        let difference2 = difference * 10
        targetWeightLabel.text = "\(targetWeight)kg"
        nowWeightLabel.text = "\(nowWeight)kg"
        differenceLabel.text = "\(floor(difference2) / 10)kg"
    }
    
    
    
    
    private func changeMonth(){
        guard let year = yearsTextField.text else {return}
        guard let month = monthsTextField.text else {return}
        weightModel.loadWeightFromFirestore(userUid: userUid, year: year, month: month)
    }
    @IBAction func tappedChangeMonthButton(_ sender: Any) {
        changeMonth()
    }
    @IBAction func tappedConfiguretionButton(_ sender: Any) {
        weightModel.sendTargetWeightToFirestore(userUid: userUid, textField: setTargetWeightTextField)
        weightModel.loadTargetWeight(userUid: userUid)
    }
}

extension ChartViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var pickerViewTitle = String()
        if pickerView.tag == 1 {
            pickerViewTitle = years[row]
            
        } else if pickerView.tag == 2 {
            pickerViewTitle =  months[row]
            
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
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = Int()
        if pickerView.tag == 1 {
            count = years.count
        } else if pickerView.tag == 2 {
            count = months.count
        }
        return count
    }
}
extension ChartViewController: WeightProtocol {
    func getData(dataArray: [PersonalData]) {
        chartArray = dataArray
        setUpChart(values: chartArray)
    }
}
extension ChartViewController:ChartViewDelegate {
    func setUpChart(values:[PersonalData]){
        
        var entry = [ChartDataEntry]()
        for i in 0..<values.count{
            entry.append(ChartDataEntry(x: Double(i), y: Double(values[i].weight)!))
        }
        let dataSet = LineChartDataSet(entries: entry, label: "体重")
        chartView.data = LineChartData(dataSet: dataSet)
    }
    func setUpLineChart(_ chart:LineChartView,data:LineChartData){
        chart.delegate = self
        chart.chartDescription?.enabled = true
        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.setViewPortOffsets(left: 30, top: 0, right: 0, bottom: 30)
        chart.legend.enabled = true
        chart.leftAxis.enabled = true
        chart.leftAxis.spaceTop = 0.4
        chart.leftAxis.spaceBottom = 0.4
        
        chart.rightAxis.enabled = false
        chart.xAxis.enabled = true
        chart.data = data
        chart.animate(xAxisDuration: 2)
    }
    
}
extension ChartViewController:UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        buttonIsEnabled()
    }
}
