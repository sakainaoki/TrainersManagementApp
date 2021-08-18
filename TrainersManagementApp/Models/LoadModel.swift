//
//  LoadModel.swift
//  TrainersManagementApp
//
//  Created by 酒井直輝 on 2021/08/15.
//

import Foundation
import Firebase

protocol GetNotReadProtocol {
    func getNotReadMessages(notReadMessages:[MessagesModel])
}
class LoadModel{
    var personalDataArray = [PersonalData]()
    var notReadMessages = [MessagesModel]()
    var getNotReadProtocol:GetNotReadProtocol?
    func loadMessageFromFirestore(){
        guard let userUid = UserDefaults.standard.object(forKey: "userUid") else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(userUid as! String).collection("messages").order(by: "timeStamp").addSnapshotListener { SnapshotMetadata, Error in
            self.notReadMessages = []
            if Error != nil{
                print("messageの取得に失敗しました。")
                return
            }
            if let snapShotDoc = SnapshotMetadata?.documents {
                for doc in snapShotDoc {
                    let data = doc.data()
                    if let sender = data["uid"] as? String,let message = data["message"] as? String,let date = data["date"] as? String,let time = data["time"] as? String,let read = data["read"] as? Bool,let dayAndTime = data["dayAndTime"] as? String{
                        let message = MessagesModel(uid: sender, message: message, date: date, time: time, read: read, dayAndTime: dayAndTime)
                        if message.read == false && message.uid != uid { 
                            self.notReadMessages.append(message)
                            print("loadModel内",self.notReadMessages.count)
                        }
                    }
                }
                self.getNotReadProtocol?.getNotReadMessages(notReadMessages: self.notReadMessages)
            }
        }
    }
}

