//
//  MealInfoViewController.swift
//  TrainersManagementApp
//
//  Created by 酒井直輝 on 2021/07/24.
//

import UIKit
import Firebase
class MealInfoViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var carbLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    
    var mealsArray:[FoodsModel] = []
    var time = String()
    var storageTime = String()
    var userUid = UserDefaults.standard.object(forKey: "userUid") as! String
    var date = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.register(UINib(nibName: "MealsInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        timeLabel.text = time
        setData()
        loadImageFromFirestore()
        // Do any additional setup after loading the view.
    }
    
    private func loadImageFromFirestore(){
        print(userUid as Any)
        print(date)
        Storage.storage().reference().child("mealImage").child(userUid).child(date).child("\(userUid + storageTime + date)").downloadURL { URL, Error in
            if Error != nil{
                print("画像の取得に失敗しました。",Error.debugDescription)
                return
            }
            if let imageString = URL?.absoluteURL {
                self.imageView.sd_setImage(with: imageString, completed: nil)
            }
            
        }
    }
    
    
    private func setData(){
        var carb = Double()
        var protein = Double()
        var fat = Double()
        var kcal = Double()
        for food in mealsArray {
            carb += Double(food.carb)!
            protein += Double(food.protein)!
            fat += Double(food.fat)!
            kcal += Double(food.kcal)!
        }
        
        carbLabel.text = String(carb)
        proteinLabel.text = String(protein)
        fatLabel.text = String(fat)
        kcalLabel.text = String(kcal)
    }
    
}
extension MealInfoViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MealsInfoTableViewCell
        cell.foodNameLabel.text = mealsArray[indexPath.row].foodName
        cell.carbLabel.text = mealsArray[indexPath.row].carb
        cell.proteinLabel.text = mealsArray[indexPath.row].protein
        cell.fatLabel.text = mealsArray[indexPath.row].fat
        cell.kcalLabel.text = mealsArray[indexPath.row].kcal
        return cell
    }
    
    
}
