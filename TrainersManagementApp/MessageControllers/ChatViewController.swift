//
//  MessageViewController.swift
//  TrainersManagementApp
//
//  Created by 酒井直輝 on 2021/08/02.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
class ChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    let userUid = UserDefaults.standard.object(forKey: "userUid") as! String
    var messages:[MessagesModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        sendButton.layer.cornerRadius = 25
        messageTextView.backgroundColor = .white
        messageTextView.layer.cornerRadius = 10
        loadMessageFromFirestore()
        sendButtonIsEnabled()
        tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "chatCell")
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    private func sendButtonIsEnabled(){
        if messageTextView.text.isEmpty == true{
            sendButton.isEnabled = false
            sendButton.backgroundColor = UIColor.rgb(red: 169, green: 169, blue: 169)
        }else{
            sendButton.isEnabled = true
            sendButton.backgroundColor = UIColor.rgb(red: 64, green: 200, blue: 224)
        }
    }
    
    private func loadMessageFromFirestore(){
        Firestore.firestore().collection("users").document(userUid).collection("messages").order(by: "timeStamp").addSnapshotListener { SnapshotMetadata, Error in
            self.messages = []
            if Error != nil{
                
                print("messageの取得に失敗しました。")
                return
            }
            if let snapShotDoc = SnapshotMetadata?.documents {
                for doc in snapShotDoc {
                    let data = doc.data()
                    if let sender = data["uid"] as? String,let message = data["message"] as? String,let date = data["date"] as? String,let time = data["time"] as? String,let read = data["read"] as? Bool,let dayAndTime = data["dayAndTime"] as? String{
                        let message = MessagesModel(uid: sender, message: message, date: date, time: time, read: read, dayAndTime: dayAndTime)
                        self.messages.append(message)
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            
                        }
                    }
                }
            }
        }
    }

    private func sendMessageToFirestore(){
        messages.removeAll()
        let date = GetDateModel.getToday()
        let time = GetDateModel.getTimeDate()
        let dayAndTime = GetDateModel.getTodayAndTimeDate()
        let read = false
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let message = messageTextView.text else {return}
        let messageDocData = ["uid":uid,
                              "message": message,
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
    
    
    @IBAction func tappedSendButton(_ sender: Any) {
        sendMessageToFirestore()
    }
}
extension ChatViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
        if messages[indexPath.row].uid == Auth.auth().currentUser?.uid {
            cell.myTextView.isHidden = false
            cell.myTimeLabel.isHidden = false
            cell.partnersTextView.isHidden = true
            cell.partnersTimeLabel.isHidden = true
            let width = estimateFrameForTextView(text: messages[indexPath.row].message).width + 20
            cell.myTextViewWidth.constant = width
            cell.myTextView.layer.cornerRadius = 10
            cell.myTextView.text = messages[indexPath.row].message
            cell.myTimeLabel.text = "\(messages[indexPath.row].time.prefix(2)):\(messages[indexPath.row].time.suffix(2))"
            
        }else{
            
            cell.partnersTextView.isHidden = false
            cell.partnersTimeLabel.isHidden = false
            cell.myTextView.isHidden = true
            cell.myTimeLabel.isHidden = true
            let width = estimateFrameForTextView(text: messages[indexPath.row].message).width + 20
            cell.partnersMessageTextViewWidth.constant = width
            cell.myTextView.layer.cornerRadius = 10
            cell.partnersTextView.text = messages[indexPath.row].message
            cell.partnersTimeLabel.text = "\(messages[indexPath.row].time.prefix(2)):\(messages[indexPath.row].time.suffix(2))"


        }
        
        return cell
    }
    private func estimateFrameForTextView(text:String) -> CGRect{
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14)], context: nil)
    }
    
}
extension ChatViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        sendButtonIsEnabled()
    }
}

