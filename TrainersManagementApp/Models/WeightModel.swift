//
//  WeightCalcModel.swift
//  TrainersManagementApp
//
//  Created by 酒井直輝 on 2021/08/09.
//

import Foundation
import Firebase

protocol WeightProtocol {
    func getData(dataArray:[PersonalData])
}

class WeightModel{
    var personalDataArray:[PersonalData] = []
    var getDataProtocol:WeightProtocol?
    func loadTargetWeight(userUid:String){
        Firestore.firestore().collection("users").document(userUid).collection("targetWeight").addSnapshotListener { SnapshotMetadata, Error in
            if Error != nil{
                print("データの取得に失敗しました。",Error.debugDescription)
                return
            }
            if let snapShotDoc = SnapshotMetadata?.documents {
                for doc in snapShotDoc {
                    let data = doc.data()
                    if let targetWeight = data["targetWeight"] as? String{
                        UserDefaults.standard.setValue(targetWeight, forKey: "\(userUid)targetWeight")
                    }
                    print("目標体重データの取得に成功しました。")
                    
                }
            }
        }
    }
    
    func sendTargetWeightToFirestore(userUid:String,textField:UITextField){
        guard let targetWeight = textField.text else {return}
        let docData = ["targetWeight":targetWeight]
        Firestore.firestore().collection("users").document(userUid).collection("targetWeight").document("targeWeight").setData(docData) { Error in
            if Error != nil{
                print("目標体重の保存に失敗しました。",Error.debugDescription)
                return
            }
        }
    }
    
    func loadWeightFromFirestore(userUid:String,year:String,month:String){
        Firestore.firestore().collection("users").document(userUid).collection("bodyWeights").document(year).collection(month).addSnapshotListener { SnapshotMetadata, Error in
            self.personalDataArray = []
            if Error != nil{
                print("体重の取得に失敗しました。",Error.debugDescription)
                return
            }
            if let snapShotDoc = SnapshotMetadata?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    if let weight = data["bodyWeight"] as? String,let date = data["date"] as? String{
                        let newPersonalData = PersonalData(weight: weight, date: date)
                        self.personalDataArray.append(newPersonalData)
//                        nowWeightLabel.text = String(describing: self.personalDataArray.last!.weight)
                        UserDefaults.standard.setValue(String(describing: self.personalDataArray.last!.weight), forKey: "\(userUid)nowWeight")
                    }
                }
            }
            
            self.getDataProtocol?.getData(dataArray: self.personalDataArray)
            
        }
    }
}
