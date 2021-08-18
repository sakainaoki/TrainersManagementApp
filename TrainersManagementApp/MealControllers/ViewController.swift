//
//  ViewController.swift
//  TrainersManagementApp
//
//  Created by 酒井直輝 on 2021/07/23.
//

import UIKit
import Firebase
import FirebaseFirestore
class ViewController: UIViewController {
    @IBOutlet weak var gestListTableView: UITableView!
    var user:User? {
        didSet {
            
        }
    }
    var userArray:[UserModel] = []
    var userName = String()
    var userUid = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        gestListTableView.delegate = self
        gestListTableView.dataSource = self
        gestListTableView.backgroundColor = .white
        gestListTableView.register(UINib(nibName: "UsersTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        loadGestInfoInFirestore()
    }

    private func loadGestInfoInFirestore(){
        Firestore.firestore().collection("users").getDocuments { SnapshotMetadata, Error in
            if Error != nil {
                print("データの取得に失敗しました。",Error.debugDescription)
                return
            }
            for doc in SnapshotMetadata!.documents {
                let data = doc.data()
                if let userName = data["userName"] as? String,let userUid = data["uid"] as? String {
                    self.userUid = userUid
                    self.userName = userName
                    let user = UserModel(userName: userName, userUid: userUid)
                    self.userArray.append(user)
                }
            }
            self.gestListTableView.reloadData()
        }
    }
}


extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.setValue(userArray[indexPath.row].userName, forKey: "userName")
        UserDefaults.standard.setValue(userArray[indexPath.row].userUid, forKey: "userUid")
        
        performSegue(withIdentifier: "tab", sender: nil)
    
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersTableViewCell
        cell.userNameLabel.text = userArray[indexPath.row].userName
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

