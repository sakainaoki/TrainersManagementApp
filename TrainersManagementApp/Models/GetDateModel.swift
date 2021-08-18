//
//  GetDateModel.swift
//  TrainersManagementApp
//
//  Created by 酒井直輝 on 2021/07/24.
//

import Foundation
class GetDateModel {
    static func getToday()->String{
        let formmater = DateFormatter()
        formmater.dateStyle = .full
        formmater.timeStyle = .none
        formmater.dateFormat = "yyyyMMdd"
        formmater.locale = Locale(identifier: "ja_JP")
        let todoy = Date()
        return formmater.string(from: todoy)
    }
    static func getTimeDate()->String{
        let formatter = DateFormatter()
        formatter.timeStyle = .full
        formatter.dateStyle = .none
        formatter.dateFormat = "Hmm"
        formatter.locale = Locale(identifier: "ja_JP")
        let time = Date()
        
        return formatter.string(from: time)
    }
    static func getTodayAndTimeDate()->String{
        let formatter = DateFormatter()
        formatter.timeStyle = .full
        formatter.dateStyle = .none
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.locale = Locale(identifier: "ja_JP")
        let time = Date()
        
        return formatter.string(from: time)
    }
}
